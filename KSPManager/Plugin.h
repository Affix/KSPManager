//
//  Plugin.h
//  KSPManager
//
//  Created by Erik O'Shaughnessy on 8/27/12.
//  Copyright (c) 2012 Symbolic Armageddon. All rights reserved.
//

#import "Asset.h"

@class PortableExecutableFormat;

@interface Plugin : Asset {
    PortableExecutableFormat *_pef;
}


@property (strong, nonatomic, readonly) NSString *installedFileName;
@property (strong, nonatomic, readonly) NSString *availableFileName;
@property (strong, nonatomic, readonly) NSString *version;
@property (strong, nonatomic, readonly) NSString *productName;
@property (strong, nonatomic, readonly) NSString *companyName;


- (id)initWithPluginFileURL:(NSURL *)pluginFileURL;
- (BOOL)movePluginTo:(NSURL *)destinationDirectoryURL;
- (BOOL)copyPluginTo:(NSURL *)destinationDirectoryURL;

+ (NSArray *)inventory:(NSURL *)baseURL;

@end
