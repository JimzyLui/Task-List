//
//  TLTaskListVC.m
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import "TLTaskListVC.h"
#import "TLAddTaskVC.h"
#import "TLTaskDetailsVC.h"

@interface TLTaskListVC ()<UITableViewDataSource,UITableViewDelegate,TLAddTaskVCDelegate,TLTaskDetailsVCDelegate>

@property(strong,nonatomic)NSMutableArray *taskList;
@property(strong,nonatomic)NSMutableArray *overDueTaskList;
@property(strong,nonatomic)NSMutableArray *completedTaskList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSString *strDateTimeFormat;
@end

@implementation TLTaskListVC

#pragma mark - Lazy Instantiation

-(NSMutableArray *)taskList
{
    if(!_taskList){
        _taskList = [[NSMutableArray alloc] init];
    }
    return _taskList;
}

-(NSMutableArray *)overDueTaskList
{
    if(!_overDueTaskList){
        _overDueTaskList = [[NSMutableArray alloc] init];
    }
    return _overDueTaskList;
}

-(NSMutableArray *)completedTaskList
{
    if(!_completedTaskList){
        _completedTaskList = [[NSMutableArray alloc] init];
    }
    return _completedTaskList;
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

	UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(addBarButtonItemPressed:)];
    [leftSwipe setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:leftSwipe];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"taskIndex" ascending:YES]];
    
    NSError *error = nil;
    
    NSArray *fetchedTasks = [[TLCoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    self.taskList = [fetchedTasks mutableCopy];

	_strDateTimeFormat = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateTimeFormatString"];

    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self.tableView setEditing:NO animated:YES];
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
    
    [self dismissViewControllerAnimated:YES completion:nil];  //if using modal
    //[self.navigationController popViewControllerAnimated:YES];

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
	switch (section) {
		case 0:
			// Overdue open
			return self.overDueTaskList.count;
			break;
		case 1:
			// Open
			return self.taskList.count;
			break;
			
		case 2:
			// Completed
			return self.completedTaskList.count;
			break;

		default:
			break;
	}
	return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Configure cell
    
    Task *task = [self.taskList objectAtIndex:indexPath.row];
    cell.textLabel.text = task.taskName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:_strDateTimeFormat];
    NSString *stringFromDate = [formatter stringFromDate:task.taskDueDate];
    cell.detailTextLabel.text = stringFromDate;
    
    BOOL isOverDue = [self isDateGreaterThanDate:[NSDate date] and:task.taskDueDate];
    
    if([task.taskIsCompleted  isEqual: TASK_COMPLETED]){
		//cell.backgroundColor = [UIColor greenColor];
		cell.imageView.image = [UIImage imageNamed:@"checkbox_checked1.png"];
		
	}
    else if(isOverDue == YES){
		cell.backgroundColor = [UIColor redColor];
		cell.imageView.image = [UIImage imageNamed:@"checkbox_unchecked1.png"];
	}
    else {
		//cell.backgroundColor = [UIColor yellowColor];
		cell.imageView.image = [UIImage imageNamed:@"checkbox_unchecked1.png"];
	}
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = self.taskList[indexPath.row];
    [self updateCompletionOfTask:task forIndexPath:indexPath];
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete object from context
        [[self.taskList[indexPath.row] managedObjectContext] deleteObject:self.taskList[indexPath.row]];
        NSError *error = nil;
        [[self.taskList[indexPath.row] managedObjectContext] save:&error];
        if(error){
            NSLog(@"error");
        }

        [self.taskList removeObjectAtIndex:indexPath.row];

        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - Navigation Methods

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

#pragma mark - IBAction Methods

- (IBAction)addBarButtonItemPressed:(UIBarButtonItem *)sender {
	[self performSegueWithIdentifier:@"toAddTaskVCSegue" sender:nil];
}



- (IBAction)reorderTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    if(self.tableView.editing == YES){
        [self.tableView setEditing:NO animated:YES];
    }
    else [self.tableView setEditing:YES animated:YES];
}


@end
