//
//  TLAddTaskVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLAddTaskVC.h"
#import "TLCoreDataHelper.h"

@interface TLAddTaskVC ()

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
    
    // give a 1 day lead to datepicker
    NSDate *now = [NSDate date];
    int daysToAdd = 1;
    self.dateDueDatePicker.date = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(Task *)returnNewTaskObject
{
    //id delegate = [[UIApplication sharedApplication] delegate];
    //NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSManagedObjectContext *context = [TLCoreDataHelper managedObjectContext];
    Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
    task.taskName = self.taskNameTextField.text;
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



- (IBAction)saveTaskBarButtonItemPressed:(UIBarButtonItem *)sender {
    if(![self.taskNameTextField.text isEqualToString:@""])
    [self.delegate didAddTask:[self returnNewTaskObject]];
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Missing Task Name"
                                                        message: @"All tasks must have a name"
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    //if wish to create multiple entries
    //self.saveBarButtonItem.title = @"Duplicate";
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
