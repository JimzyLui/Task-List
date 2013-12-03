//
//  TLAddTaskVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@protocol TLAddTaskVCDelegate <NSObject>

-(void)didCancel;
-(void)didAddTask:(Task *)task;

@end
@interface TLAddTaskVC : UIViewController<UITextViewDelegate,UITextFieldDelegate>

@property(weak,nonatomic)id<TLAddTaskVCDelegate>delegate;

@property (strong, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (strong, nonatomic) IBOutlet UITextView *taskDetailsTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateDueDatePicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

- (IBAction)saveTaskBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
