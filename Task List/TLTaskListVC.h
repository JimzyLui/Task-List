//
//  TLTaskListVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLAddTaskVC.h"
#import "TLTaskDetailsVC.h"

@interface TLTaskListVC : UIViewController<UITableViewDelegate,UITableViewDataSource,TLAddTaskVCDelegate,TLTaskDetailsVCDelegate>

@property(strong,nonatomic)NSMutableArray *taskList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addTaskBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)reorderTaskBarButtonPressed:(UIBarButtonItem *)sender;


@end
