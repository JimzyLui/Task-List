//
//  TLEditTaskVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@protocol TLEditTaskVCDelegate <NSObject>

-(void)didUpdateTask;

@end
@interface TLEditTaskVC : UIViewController<UITextFieldDelegate,UITextViewDelegate>

@property(weak,nonatomic)id<TLEditTaskVCDelegate>delegate;

@property(strong,nonatomic)Task *task;
@property (strong, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (strong, nonatomic) IBOutlet UITextView *taskDetailsTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *taskDueDatePicker;
@property (strong, nonatomic) IBOutlet UISwitch *isCompletedSwitch;

@property (strong, nonatomic) IBOutlet UILabel *isCompletedLabel;

- (IBAction)isCompletedSwitchChanged:(UISwitch *)sender;
- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender;


@end
