//
//  TLTaskDetailsVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TLTaskDetailsVCDelegate <NSObject>

-(void)didUpdateTask;

@end
@interface TLTaskDetailsVC : UIViewController

@property(weak,nonatomic)id<TLTaskDetailsVCDelegate>delegate;
@property(strong,nonatomic)Task *task;


//- (IBAction)isCompletedSwitchChanged:(UISwitch *)sender;
//- (IBAction)editTaskBarButtonItemPressed:(UIBarButtonItem *)sender;


@end
