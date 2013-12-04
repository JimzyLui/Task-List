//
//  TLTaskListVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLTaskListVC.h"
#import "TLCoreDataHelper.h"
#import "Task.h"

@interface TLTaskListVC ()

@end

@implementation TLTaskListVC



//lazy instantiation
-(NSMutableArray *)taskList
{
    if(!_taskList){
        _taskList = [[NSMutableArray alloc] init];
    }
    return _taskList;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    NSLog(@"initWithNibName");
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;  //so tableview protocol knows to send messages to me
    self.tableView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"taskIndex" ascending:YES]];
    
    NSError *error = nil;
    
    NSArray *fetchedTasks = [[TLCoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    self.taskList = [fetchedTasks mutableCopy];
    
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(self.tableView.editing == YES)
        [self.tableView setEditing:NO animated:YES];

    if([segue.destinationViewController isKindOfClass:[TLAddTaskVC class]]){
        TLAddTaskVC *addTaskVC = segue.destinationViewController;
        addTaskVC.delegate = self;
    }
    
    else if([segue.destinationViewController isKindOfClass:[TLTaskDetailsVC class]]){
        TLTaskDetailsVC *detailTaskVC = segue.destinationViewController;

        NSIndexPath *path = sender;

        Task *taskObject = self.taskList[path.row];
        detailTaskVC.task = taskObject;
        detailTaskVC.delegate = self;
    }    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TLAddTaskVCDelegate

-(void)didAddTask:(Task *)task
{
    [self.taskList addObject:task];
    
    NSManagedObjectContext *context = [TLCoreDataHelper managedObjectContext];
    task.taskIndex = [NSNumber numberWithInt:[self.taskList count]];
    
    NSError *error = nil;
    if  (![context save:&error]){
        //we have an error!
        NSLog(@"%@",error);
    }
    
    //[self dismissViewControllerAnimated:YES completion:nil];  //if using modal
    [self.navigationController popViewControllerAnimated:YES];

    [self.tableView reloadData];
}



#pragma mark - TLDetailVCDelegate
-(void)didUpdateTask
{
    [self reIndexArray];
    //[self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}


#pragma mark - helper methods

-(BOOL)isDateGreaterThanDate:(NSDate *)date and:(NSDate *)toDate
{
    NSTimeInterval dateInterval = [date timeIntervalSince1970];
    NSTimeInterval toDateInterval = [toDate timeIntervalSince1970];
    
    if(dateInterval > toDateInterval) return YES;
    else return NO;
}

-(void)updateCompletionOfTask:(Task *)task forIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"updateCompletionOfTask called");
    if([task.taskIsCompleted  isEqual: TASK_COMPLETED]){
        task.taskIsCompleted = TASK_NOT_COMPLETED;
    } else {
        task.taskIsCompleted = TASK_COMPLETED;
    }
    
    NSError *error = nil;
    if (![[task managedObjectContext] save:&error]) {
        //Handle Error
        NSLog(@"updateCompletionOfTask: Save Error:%@", error);
    }
    
    [self.tableView reloadData];
}



-(void)reIndexArray
{
    for(int x = 0;x < [self.taskList count]; x++){
        Task *t = self.taskList[x];
        NSError *error = nil;
        if (![[t managedObjectContext] save:&error]) {
            //Handle Error
            NSLog(@"%@", error);
        }
        t.taskIndex = [NSNumber numberWithInt:x];
        [self.taskList replaceObjectAtIndex:x withObject:t];
    }
    
}

#pragma mark - UITableViewDataSouce

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taskList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Configure cell
    
    Task *task = [self.taskList objectAtIndex:indexPath.row];
    cell.textLabel.text = task.taskName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATETIME_FORMAT];
    NSString *stringFromDate = [formatter stringFromDate:task.taskDueDate];
    cell.detailTextLabel.text = stringFromDate;
    
    BOOL isOverDue = [self isDateGreaterThanDate:[NSDate date] and:task.taskDueDate];
    
    if([task.taskIsCompleted  isEqual: TASK_COMPLETED]) cell.backgroundColor = [UIColor greenColor];
    else if(isOverDue == YES) cell.backgroundColor = [UIColor redColor];
    else cell.backgroundColor = [UIColor yellowColor];
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = self.taskList[indexPath.row];
    [self updateCompletionOfTask:task forIndexPath:indexPath];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle ==UITableViewCellEditingStyleDelete){
        //remove from CoreData
        [[self.taskList[indexPath.row] managedObjectContext] deleteObject:self.taskList[indexPath.row]];
        
        NSError *error = nil;
        [[self.taskList[indexPath.row] managedObjectContext] save:&error];
        if(error){
            NSLog(@"error");
        }
        
        //remove the selected cell from the array
        [self.taskList removeObjectAtIndex:indexPath.row];
        
        //update table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailVCSegue" sender:indexPath];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Task *taskObj = [self.taskList objectAtIndex:sourceIndexPath.row];
    [self.taskList removeObjectAtIndex:sourceIndexPath.row];
    [self.taskList insertObject:taskObj atIndex:destinationIndexPath.row];
    
    [self reIndexArray];
    //NSLog(@"Reordered");
    //[self saveTask:];
}

#pragma mark - IBAction Methods

- (IBAction)addTaskBarButtonPressed:(UIBarButtonItem *)sender
{

}

- (IBAction)reorderTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    if(self.tableView.editing == YES){
        [self.tableView setEditing:NO animated:YES];
    }
    else [self.tableView setEditing:YES animated:YES];
}


@end
