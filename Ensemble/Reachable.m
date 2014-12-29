//
//  Reachable.m
//  Ensemble
//
//  Created by Adam on 9/16/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "Reachable.h"

@implementation Reachable

+(BOOL)internetNetworkIsUnreachable
{
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable)
	{
		return YES;
	}
	
	return NO;
}

+(BOOL)wifiNetworkIsUnreachable
{
	Reachability *wifiReachability = [Reachability reachabilityForLocalWiFi];
	NetworkStatus wifiStatus = [wifiReachability currentReachabilityStatus];
	if (wifiStatus == NotReachable)
	{
		return YES;
	}
	
	return NO;
}

@end
