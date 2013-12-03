//
//  TLTaskDetailsVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "TLEditTaskVC.h"

@protocol TLTaskDetailsVCDelegate <NSObject>

-(void)didUpdateTask;

@end
@interface TLTaskDetailsVC : UIViewController<TLEditTaskVCDelegate>

@property(weak,nonatomic)id<TLTaskDetailsVCDelegate>delegate;

@property(strong,nonatomic)Task *task;
@property (strong, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskDetailsLabel;
@property (strong, nonatomic) IBOutlet UISwitch *isCompletedSwitch;

@property (strong, nonatomic) IBOutlet UILabel *isCompletedLabel;

- (IBAction)isCompletedSwitchChanged:(UISwitch *)sender;
- (IBAction)editTaskBarButtonItemPressed:(UIBarButtonItem *)sender;


@end
