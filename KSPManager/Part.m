//
//  Part.m
//  KSPManager
//
//  Created by Erik O'Shaughnessy on 8/15/12.
//  Copyright (c) 2012 Symbolic Armageddon. All rights reserved.
//

#import "Part.h"

@implementation Part

@synthesize partDirectoryName = _partDirectoryName;
@synthesize configurationURL = _configurationURL;
@synthesize detail = _detail;
@synthesize categoryName = _categoryName;
@synthesize MODULE = _MODULE;
@synthesize INTERNAL = _INTERNAL;



- (id)initWithConfigurationFileURL:(NSURL *)cfgURL
{
    if( [cfgURL checkResourceIsReachableAndReturnError:nil] == NO )
        return nil;
    
    if( self = [super initWithURL:[cfgURL URLByDeletingLastPathComponent]] ) {
         self.configurationURL = cfgURL;
        NSStringEncoding encoding;
        
        _globalContext = [[NSMutableDictionary alloc] init];
        
        NSArray *lines = [LineToken linesFromURL:self.configurationURL
                                    withEncoding:&encoding
                                     withOptions:@{ kLineOptionCommentTokenKey : @"//" }];
        
        _parser = [ConfigurationParser parserWithLineTokens:lines];
        _parser.delegate = self;
        [_parser beginParsing];
    }
    return self;
}



#pragma mark -
#pragma mark Properties

- (NSString *)assetTitle
{
    return [self valueForKey:kPartKeyTitle];
}

- (NSString *)assetCategory
{
    return self.categoryName;
}

- (NSString *)partDirectoryName
{
    if( _partDirectoryName == nil ){
        _partDirectoryName = [self.baseURL lastPathComponent];
    }
    return _partDirectoryName;
}


- (void)setConfigurationURL:(NSURL *)configurationURL
{
    if( _configurationURL == configurationURL )
        return ;
    
    _configurationURL = configurationURL;
}

- (NSMutableDictionary *)MODULE
{
    if( _MODULE == nil ) {
        _MODULE = [[NSMutableDictionary alloc] initWithDictionary:@{ @"ContextName":kPartKeyModuleContext}];
    }
    return _MODULE;
}

- (NSMutableDictionary *)INTERNAL
{
    if( _INTERNAL == nil ) {
        _INTERNAL = [[NSMutableDictionary alloc] initWithDictionary:@{ @"ContextName":kPartKeyInternalContext}];
    }
    return _INTERNAL;
}

 
- (NSString *)detail
{
    if( _detail == nil ) {
        _detail = @"";
        
        for(NSDictionary *ctx in @[ _globalContext, self.MODULE, self.INTERNAL ]) {
         
            for(NSString *key in [ctx.allKeys sortedArrayUsingSelector:@selector(localizedCompare:)]) {
                
                if( [key isEqualToString:@"ContextName"] )
                    continue;
                
                NSString *prefix = @"";
                
                if( ctx != _globalContext )
                    prefix = [NSString stringWithFormat:@"%@.",[ctx valueForKey:@"ContextName"]];
                
                _detail = [_detail stringByAppendingFormat:@"\t%@%@ -> %@\n",prefix,key,[ctx valueForKey:key]];

            }
            
        }

    }
    return _detail;
}

- (NSString *)categoryName
{
    NSString *val = [self valueForKey:kPartKeyCategory];
    return [[Part categoryNames] objectAtIndex:val.integerValue];
}


#pragma mark -
#pragma mark Overriden Properties

- (BOOL)isInstalled
{
    NSRange range =[self.baseURL.path rangeOfString:kKSP_MODS];
    
    // if currentURL.path doesn't contain kKSP_MODS, installed == YES
    
    return (range.location == NSNotFound);
}



#pragma mark -
#pragma mark Instance Methods


- (BOOL)movePartTo:(NSURL *)destinationDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *targetURL = [destinationDirectoryURL URLByAppendingPathComponent:self.partDirectoryName isDirectory:YES];
    
    NSError *error = nil;
    
    [fileManager moveItemAtURL:self.baseURL toURL:targetURL error:&error];
    
    if( error ){
        self.error = error;
        return NO;
    }
    
    self.baseURL = targetURL;

    self.error = nil;
    
    return YES;
}

- (BOOL)copyPartTo:(NSURL *)destinationDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *targetURL = [destinationDirectoryURL URLByAppendingPathComponent:self.partDirectoryName isDirectory:YES];
    
    NSError *error = nil;
    
    [fileManager copyItemAtURL:self.baseURL toURL:targetURL error:&error];
    
    if( error ) {
        self.error = error;
        return NO;
    }
    
    self.baseURL = targetURL;
    
    self.error = nil;

    return YES;
}

- (void)addEntriesFromDictionary:(NSDictionary *)newEntries
{
    [_globalContext addEntriesFromDictionary:newEntries];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //    NSLog(@"setValue:%@ forUndefinedKey: %@",value,key);
    [_globalContext setValue:value forUndefinedKey:key];  
}


- (id)valueForUndefinedKey:(NSString *)key
{
    return [_globalContext valueForKey:key];
}



#pragma mark -
#pragma mark ConfigurationParserDelegate

- (void)willBeginParsingWithConfiguration:(ConfigurationParser *)tokenizer
{
    NSLog(@"beginParse %ld lines for %@",tokenizer.lines.count,self.configurationURL.lastPathComponent);
}

- (BOOL)handleNewContext:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
     return YES;
}

- (BOOL)handleKeyValue:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
    
    if( tokenizer.isGlobal ) {
        [self addEntriesFromDictionary:line.keyValue];
        return YES;
    }
    
    if( [tokenizer.currentContext isEqualToString:kPartKeyModuleContext] ) {
        [self.MODULE addEntriesFromDictionary:line.keyValue];
        return YES;
    }
    
    if( [tokenizer.currentContext isEqualToString:kPartKeyInternalContext] ) {
        [self.INTERNAL addEntriesFromDictionary:line.keyValue];
        return YES;
    }
    
    return NO;
}


- (BOOL)handleUnknownContent:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
    NSLog(@"UnknownContent: %@ %@",tokenizer.currentContext,line.content);
    
    return NO;
}



#pragma mark -
#pragma mark Class Methods


+ (NSArray *)inventory:(NSURL *)baseURL
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSArray *partCfgPaths = [self assetSearch:baseURL usingBlock:^BOOL(NSString *path) {
        return [[path lastPathComponent] isEqualToString:kPART_CONFIG];
    }];

    for(NSString *cfgPath in partCfgPaths){
        Part *part = [[Part alloc]initWithConfigurationFileURL:[baseURL URLByAppendingPathComponent:cfgPath]];
        if( part )
            [results addObject:part];
    }
    
    return results;
}



+ (NSArray *)categoryNames
{
    return @[kPART_PROPULSION,kPART_COMMAND,kPART_STRUCTURAL,kPART_UTILITY,kPART_DECAL,kPART_CREW];
}

@end
