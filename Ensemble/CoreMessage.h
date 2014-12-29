//
//  CoreMessage.h
//  Ensemble
//
//  Created by Adam on 9/27/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreMessage : NSManagedObject

@property (nonatomic, retain) NSString * messageReceiverID;
@property (nonatomic, retain) NSString * messageReceiverName;
@property (nonatomic, retain) NSString * messageSenderID;
@property (nonatomic, retain) NSString * messageSenderName;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) NSDate * messageDate;

@end
