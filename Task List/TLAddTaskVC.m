//
//  TLAddTaskVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLAddTaskVC.h"
//#import "TLCoreDataHelper.h"

@interface TLAddTaskVC ()<UITextViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (strong, nonatomic) IBOutlet UITextView *taskDetailsTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateDueDatePicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation TLAddTaskVC


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
    self.taskNameTextField.delegate = self;
    self.taskDetailsTextView.delegate = self;

    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBackToPreviousScreen)];
    [self.view addGestureRecognizer:rightSwipe];
    [self.view addGestureRecognizer:rightSwipe];
}

-(void)viewWillAppear:(BOOL)animated
{

	int iDaysBeforeDue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInDays"];
	int iHoursBeforeDue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInHours"];
	int iMinutesBeforeDue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInMinutes"];
	NSString *strTimeStyle = [[NSUserDefaults standardUserDefaults] stringForKey:@"timeStyle"];

    // give a 1 day lead to datepicker
    NSDate *now = [NSDate date];
    //self.dateDueDatePicker.date = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
	int iDaysInterval = 60*60*24*iDaysBeforeDue;
	int iHoursInterval = 60*60*iHoursBeforeDue;
	int iMinutesInterval = 60*iMinutesBeforeDue;
	int iTimeInterval = iDaysInterval + iHoursInterval + iMinutesInterval;
    self.dateDueDatePicker.date = [now dateByAddingTimeInterval:iTimeInterval];
	if ([strTimeStyle  isEqual: @"None"]) {
		self.dateDueDatePicker.datePickerMode = UIDatePickerModeDate;
	} else{
		self.dateDueDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
	}


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

-(Task *)returnNewTaskObject
{
    NSManagedObjectContext *context = [TLCoreDataHelper managedObjectContext];
    Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
    task.taskName = [self.taskNameTextField.text capitalizedString];
    task.taskDescription = self.taskDetailsTextView.text;
    task.taskDueDate = self.dateDueDatePicker.date;
    task.taskIsCompleted = TASK_NOT_COMPLETED;
    task.taskIndex = @5000;
    
    NSError *error = nil;
    
    if  (![context save:&error]){
        //we have an error!
        NSLog(@"%@",error);
    }
    return task;
}

#pragma mark - IBAction Methods
- (IBAction)saveButtonPressed:(UIButton *)sender
{
    if(![self.taskNameTextField.text isEqualToString:@""])
		[self.delegate didAddTask:[self returnNewTaskObject]];
    else{
        UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Missing Task Name"
							  message: @"All tasks must have a name"
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
        [alert show];
    }
    //if wish to create multiple entries
    //self.saveBarButtonItem.title = @"Duplicate";
}
- (IBAction)cancelButtonPressed:(UIButton *)sender
{
	[self goBackToPreviousScreen];
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
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
