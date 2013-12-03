//
//  TLEditTaskVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLEditTaskVC.h"

@interface TLEditTaskVC ()

@end

@implementation TLEditTaskVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.taskNameTextField.text = self.task.taskName;
    self.taskDetailsTextView.text = self.task.taskDescription;
    self.taskDueDatePicker.date = self.task.taskDueDate;
    
    [self isCompleted:self.task.taskIsCompleted];  //sets switch settings
    
    //setup delegates for removing keyboard
    self.taskNameTextField.delegate = self;
    self.taskDetailsTextView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)isCompleted:(NSNumber*)isCompleted
{
    if ([isCompleted  isEqual: TASK_COMPLETED]) {
        self.isCompletedSwitch.on = YES;
        self.isCompletedLabel.text = SWITCH_ON;
    } else {
        self.isCompletedSwitch.on = NO;
        self.isCompletedLabel.text = SWITCH_OFF;
    }
}

- (IBAction)isCompletedSwitchChanged:(UISwitch *)sender {
    if (self.isCompletedSwitch.on) {
        self.isCompletedLabel.text = SWITCH_ON;
        //self.task.taskIsCompleted = TASK_COMPLETED;  //wait till saved
    } else{
        self.isCompletedLabel.text = SWITCH_OFF;
        //self.task.taskIsCompleted = TASK_NOT_COMPLETED;  //wait till saved
    }
}

- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender {
    [self updateTask];
    [self.delegate didUpdateTask];
}

-(void)updateTask
{
    self.task.taskName = self.taskNameTextField.text;
    self.task.taskDescription = self.taskDetailsTextView.text;
    self.task.taskDueDate = self.taskDueDatePicker.date;
    if (self.isCompletedSwitch.on) self.task.taskIsCompleted = TASK_COMPLETED;
    else self.task.taskIsCompleted = TASK_NOT_COMPLETED;
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.taskNameTextField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //"this is a hacky solution"  - meaning, not the best
    if([text isEqualToString:@"\n"]){
        [self.taskDetailsTextView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end