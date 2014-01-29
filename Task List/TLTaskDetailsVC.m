//
//  TLTaskDetailsVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLTaskDetailsVC.h"
#import "TLEditTaskVC.h"

@interface TLTaskDetailsVC ()<TLEditTaskVCDelegate>
@property (strong, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskDetailsLabel;
@property (strong, nonatomic) IBOutlet UISwitch *isCompletedSwitch;
@property (strong, nonatomic) IBOutlet UILabel *isCompletedLabel;

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

	NSString *strDateTimeFormat = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateTimeFormatString"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:strDateTimeFormat];
    NSString *strDate = [formatter stringFromDate:self.task.taskDueDate];
    
    self.dateLabel.text = strDate;

	UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBackToPreviousScreen)];
    [self.view addGestureRecognizer:rightSwipe];
    [self.view addGestureRecognizer:rightSwipe];

    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(editBarButtonItemPressed:)];
    [leftSwipe setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:leftSwipe];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods
- (IBAction)editBarButtonItemPressed:(UIBarButtonItem *)sender
{
	[self performSegueWithIdentifier:@"toEditVCSegue" sender:sender];
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
        self.task.taskIsCompleted = TASK_COMPLETED;
    } else{
        self.isCompletedLabel.text = SWITCH_OFF;
        self.task.taskIsCompleted = TASK_NOT_COMPLETED;
    }
    [self.delegate didUpdateTask];
}

#pragma mark - Navigation Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[TLEditTaskVC class]]){
        TLEditTaskVC *editTaskVC = segue.destinationViewController;
        editTaskVC.task = self.task;  //so now the task here is 
        editTaskVC.delegate = self;
    }
}
-(void)goBackToPreviousScreen
{
    // go back one screen
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegate Methods

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
