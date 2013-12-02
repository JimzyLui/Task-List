//
//  Task.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * taskName;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSDate * taskDueDate;
@property (nonatomic, retain) NSNumber * taskPriority;
@property (nonatomic, retain) NSNumber * taskIsCompleted;
@property (nonatomic, retain) NSDate * taskLastUpdated;
@property (nonatomic, retain) NSDate * taskCompletionDate;

@end
