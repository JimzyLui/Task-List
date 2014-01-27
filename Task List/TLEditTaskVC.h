//
//  TLEditTaskVC.h
//  Task List
//
//  Created by Jimzy Lui on 12/1/2013.
//  Copyright (c) 2013 Jimzy Lui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TLEditTaskVCDelegate <NSObject>

-(void)didUpdateTask;

@end
@interface TLEditTaskVC : UIViewController

@property(weak,nonatomic)id<TLEditTaskVCDelegate>delegate;
@property(strong,nonatomic)Task *task;


//- (IBAction)isCompletedSwitchChanged:(UISwitch *)sender;
//- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender;


@end
