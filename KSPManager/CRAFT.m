//
//  CRAFT.m
//  KSPManager
//
//  Created by Erik O'Shaughnessy on 9/26/12.
//  Copyright (c) 2012 Symbolic Armageddon. All rights reserved.
//

#import "CRAFT.h"
#import "SFSVessel.h"

@interface CRAFT () {
    NSMutableDictionary *_options;
}

@property (strong, nonatomic, readwrite) SFSVessel *vessel;
@property (strong, nonatomic, readwrite) SFSPart *part;

@end

@implementation CRAFT

@synthesize vessel = _vessel;
@synthesize part = _part;

#pragma mark -
#pragma mark LifeCycle



#pragma mark -
#pragma mark Properties

- (SFSVessel *)vessel
{
    if( _vessel == nil ) {
        _vessel = [[SFSVessel alloc] init];
    }
    return _vessel;
}

- (SFSPart *)part
{
    if( _part == nil ) {
        _part = [[SFSPart alloc] init];
    }
    return _part;
}

#pragma mark -
#pragma mark Instance Methods

#pragma mark -
#pragma mark ConfigurationParserDelegate Methods


- (BOOL)handleNewContext:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
    if( [SFSPart keywordMatch:tokenizer.currentContext] ) {
        return YES;
    }
    
    if( [SFSModule keywordMatch:tokenizer.currentContext] ) {

        return YES;
    }
    
    if( [SFSModule keywordMatch:tokenizer.currentContext] ) {
        return YES;
    }

    return NO;
}

- (BOOL)handleBeginContext:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
    _options = [[NSMutableDictionary alloc] init];
    
    return YES;
}

- (BOOL)handleKeyValue:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
    if ( tokenizer.isGlobal ) {
        [self.vessel addEntriesFromDictionary:line.keyValue];
        return YES;
    }
    
    if( [SFSPart keywordMatch:tokenizer.currentContext] ) {
        [self.part addEntriesFromDictionary:line.keyValue];
        return YES;
    }
    
    if( [SFSModule keywordMatch:tokenizer.currentContext] ) {
        [_options addEntriesFromDictionary:line.keyValue];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleEndContext:(LineToken *)line inConfiguration:(ConfigurationParser *)tokenizer
{
    if( [SFSPart keywordMatch:tokenizer.currentContext] ) {
        [self.vessel addPart:self.part];
        self.part = nil;
        return YES;
    }

    if( [SFSModule keywordMatch:tokenizer.currentContext] ) {
        [self.part addModuleWithOptions:_options];
        return YES;
    }

    return NO;
}



#pragma mark -
#pragma mark Class Methods

+ (SFSVessel *)vesselForContentsOfURL:(NSURL *)url
{
    CRAFT *craft = [[CRAFT alloc] initWithContentsOfURL:url];
    
    return craft.vessel;
}

@end
