//
//  TLEditTaskVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLEditTaskVC.h"

@interface TLEditTaskVC ()<UITextFieldDelegate,UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (strong, nonatomic) IBOutlet UITextView *taskDetailsTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *taskDueDatePicker;
@property (strong, nonatomic) IBOutlet UISwitch *isCompletedSwitch;
@property (strong, nonatomic) IBOutlet UILabel *isCompletedLabel;

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


	UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBackToPreviousScreen)];
    [self.view addGestureRecognizer:rightSwipe];
    [self.view addGestureRecognizer:rightSwipe];
}

-(void)viewWillAppear:(BOOL)animated
{
	NSString *strTimeStyle = [[NSUserDefaults standardUserDefaults] stringForKey:@"timeStyle"];
	if ([strTimeStyle  isEqual: @"None"]) {
		self.taskDueDatePicker.datePickerMode = UIDatePickerModeDate;
	} else{
		self.taskDueDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
	}

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

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

#pragma mark - IBAction Methods

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


#pragma mark - Delegate Methods

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

#pragma mark - Navigation Methods

-(void)goBackToPreviousScreen
{
    // go back one screen
    [self.navigationController popViewControllerAnimated:YES];
}
@end