//
//  Reachable.h
//  Ensemble
//
//  Created by Adam on 9/16/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface Reachable : NSObject

+(BOOL)internetNetworkIsUnreachable;
+(BOOL)wifiNetworkIsUnreachable;

@end
