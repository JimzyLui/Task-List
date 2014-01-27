//
//  TLAddTaskVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Task.h"

@protocol TLAddTaskVCDelegate <NSObject>

-(void)didAddTask:(Task *)task;

@end
@interface TLAddTaskVC : UIViewController

@property(weak,nonatomic)id<TLAddTaskVCDelegate>delegate;


//- (IBAction)saveTaskBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
