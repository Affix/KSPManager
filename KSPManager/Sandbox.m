//
//  Sandbox.m
//  KSPManager
//
//  Created by Erik O'Shaughnessy on 9/22/12.
//  Copyright (c) 2012 Symbolic Armageddon. All rights reserved.
//

#import "Sandbox.h"
#import "SFS.h"
#import "Ship.h"

@interface Sandbox () {
    SFSGame *_game;
}

@property (strong, nonatomic, readwrite) NSMutableArray *ships;

@end


@implementation Sandbox

@synthesize ships = _ships;

#pragma mark -
#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)baseURL
{
    if( self = [super initWithURL:baseURL] ) {
        _game = [SFS gameFromContentsOfURL:self.baseURL];
    }
    return self;
}

#pragma mark -
#pragma mark Properties

- (NSMutableArray *)ships
{
    if( _ships == nil ) {
        _ships = [[NSMutableArray alloc] init];
        [_ships addObjectsFromArray:[Ship inventory:[self.baseURL URLByDeletingLastPathComponent]]];
    }
    return _ships;
}

- (BOOL)isInstalled
{
    return [self.baseURL.path rangeOfString:kKSPManagedRoot].location == NSNotFound;
}

- (BOOL)isAvailable
{
    return [self.baseURL.path rangeOfString:kKSPManagedRoot].location != NSNotFound;
}

- (NSString *)assetTitle
{
    return @"sandbox";
}

- (NSString *)assetCategory
{
    return @"Sandbox";
}



#pragma mark -
#pragma mark Instance Methods

- (BOOL)moveTo:(NSURL *)destinationDirURL
{
    return NO;
}

- (BOOL)copyTo:(NSURL *)destinationDirURL
{
    return NO;
}

- (BOOL)remove
{
    return NO;
}

- (BOOL)rename:(NSURL *)newName
{
    return NO;
}

#pragma mark -
#pragma mark Class Methods
+ (NSArray *)inventory:(NSURL *)baseURL
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSArray *sfsPaths = [self assetSearch:baseURL usingBlock:^BOOL(NSString *path) {
        return [path.lastPathComponent isEqualToString:kKSP_PERSISTENT];
    }];
    
    for(NSString *sfsPath in sfsPaths) {
        Sandbox *sandbox = [[Sandbox alloc] initWithURL:[baseURL URLByAppendingPathComponent:sfsPath]];
        if( sandbox )
            [results addObject:sandbox];
    }
    
    return results;
}


@end
