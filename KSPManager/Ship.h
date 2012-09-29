//
//  Ship.h
//  KSPManager
//
//  Created by Erik O'Shaughnessy on 9/10/12.
//  Copyright (c) 2012 Symbolic Armageddon. All rights reserved.
//

#import "Asset.h"


@interface Ship : Asset

@property (strong,nonatomic, readonly) NSMutableArray *parts;
@property (strong,nonatomic, readonly) NSString *hangerName;
@property (assign,nonatomic, readonly) BOOL isInSpacePlaneHanger;
@property (assign,nonatomic, readonly) BOOL isInVehicleAssemblyBuilding;
@property (assign,nonatomic, readonly) BOOL isSandboxed;

@end
