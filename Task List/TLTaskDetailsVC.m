//
//  TLTaskDetailsVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLTaskDetailsVC.h"

@interface TLTaskDetailsVC ()

@end

@implementation TLTaskDetailsVC

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

}

-(void)viewWillAppear:(BOOL)animated
{
    //populate the fields
    self.taskNameLabel.text = self.task.taskName;
    self.taskDetailsLabel.text = self.task.taskDescription;
    //[self.taskDetailsLabel sizeToFit];  //doesn't work to top align - save for reference
    
    [self isCompleted:self.task.taskIsCompleted];  //sets switch settings
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATETIME_FORMAT];
    NSString *strDate = [formatter stringFromDate:self.task.taskDueDate];
    
    self.dateLabel.text = strDate;
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
        self.task.taskIsCompleted = TASK_COMPLETED;
    } else{
        self.isCompletedLabel.text = SWITCH_OFF;
        self.task.taskIsCompleted = TASK_NOT_COMPLETED;
    }
    [self.delegate didUpdateTask];
}



- (IBAction)editTaskBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"toEditVCSegue" sender:sender];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[TLEditTaskVC class]]){
        TLEditTaskVC *editTaskVC = segue.destinationViewController;
        editTaskVC.task = self.task;  //so now the task here is 
        editTaskVC.delegate = self;
    }
}

-(void)didUpdateTask
{
    self.taskNameLabel.text = self.task.taskName;
    self.taskDetailsLabel.text = self.task.taskDescription;

    if ([self.task.taskIsCompleted  isEqual: TASK_COMPLETED]) self.isCompletedSwitch.on = YES;
    else self.isCompletedSwitch.on = NO;
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATETIME_FORMAT];
    NSString *strDate = [formatter stringFromDate:self.task.taskDueDate];
    self.dateLabel.text = strDate;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.delegate didUpdateTask];
}

@end
