//
//  TLSettingsVC.m
//  Task List
//
//  Created by Jimzy Lui on 1/25/2014.
//  Copyright (c) 2014 Jimzy Lui. All rights reserved.
//

#import "TLSettingsVC.h"

@interface TLSettingsVC ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *showWeekdaySwitch;
@property (strong, nonatomic) IBOutlet UISwitch *isFullYearSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasLeadingZerosSwitch;
//@property (strong, nonatomic) IBOutlet UISegmentedControl *timeTypeSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timeStyleSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *dateStyleSegmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *daysBeforeDueTextField;
@property (strong, nonatomic) IBOutlet UITextField *hoursBeforeDueTextField;
@property (strong, nonatomic) IBOutlet UITextField *minutesBeforeDueTextField;
@property(nonatomic)int iDays;
@property(nonatomic)int iHours;
@property(nonatomic)int iMinutes;
@property(nonatomic)BOOL addDone;
@property(strong,nonatomic)NSString *strDateTimeFormat;

@end

@implementation TLSettingsVC

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

	self.daysBeforeDueTextField.delegate = self;
	self.minutesBeforeDueTextField.delegate = self;
	self.hoursBeforeDueTextField.delegate = self;


}

-(void)viewWillAppear:(BOOL)animated
{
	self.showWeekdaySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"showWeekday"];
    [self.showWeekdaySwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

	self.isFullYearSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFullYear"];
    [self.isFullYearSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

	self.hasLeadingZerosSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLeadingZeros"];
    [self.hasLeadingZerosSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

	NSString *strDateStyle = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateStyle"];
	if ([strDateStyle  isEqual: @"Western"]) {
		self.dateStyleSegmentedControl.selectedSegmentIndex = 0;
	} else if([strDateStyle isEqual:@"European"]){
		self.dateStyleSegmentedControl.selectedSegmentIndex = 1;
	} else {  // Military
		self.dateStyleSegmentedControl.selectedSegmentIndex = 2;
	}
	[self.dateStyleSegmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];


	NSString *strTimeStyle = [[NSUserDefaults standardUserDefaults] stringForKey:@"timeStyle"];
	if ([strTimeStyle  isEqual: @"None"]) {
		self.timeStyleSegmentedControl.selectedSegmentIndex = 0;
	} else 	if ([strTimeStyle  isEqual: @"Regular"]) {
		self.timeStyleSegmentedControl.selectedSegmentIndex = 1;
	} else {  // Military
		self.timeStyleSegmentedControl.selectedSegmentIndex = 2;
	}
    [self.timeStyleSegmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

	self.iMinutes = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInMinutes"];
	self.minutesBeforeDueTextField.text = [NSString stringWithFormat:@"%i",self.iMinutes];
    [self.minutesBeforeDueTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

	self.iHours = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInHours"];
	self.hoursBeforeDueTextField.text = [NSString stringWithFormat:@"%i",self.iHours];
	[self.hoursBeforeDueTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];


	self.iDays = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInDays"];
 	self.daysBeforeDueTextField.text = [NSString stringWithFormat:@"%i",self.iDays];
	[self.daysBeforeDueTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	NSLog(@"Retrieved Days: %i", self.iDays);

	_strDateTimeFormat = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateTimeFormatString"];

	self.minutesBeforeDueTextField.tag = 1;
	self.hoursBeforeDueTextField.tag = 2;
	self.daysBeforeDueTextField.tag = 3;

	//NSDate *now = [NSDate date];
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[self generateDateTimeFormatString];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods

#pragma mark - Helper Methods

-(void)generateDateTimeFormatString
{
	NSString *strFormat;
	NSString *strYear;
	NSString *strMonth;
	NSString *strDay;
	//NSString *strHour;
	NSString *strSeparator = @"/";
	NSString *strTime;
	NSString *strWeekday;
	NSString *strDate;
	strYear =  (self.isFullYearSwitch.isOn) ? @"yyyy" : @"yy";
	strMonth =  (self.hasLeadingZerosSwitch.isOn) ? @"MM" : @"M";
	strDay =  (self.hasLeadingZerosSwitch.isOn) ? @"dd" : @"d";
	strWeekday =  (self.showWeekdaySwitch.isOn) ? @"EEE, " : @"";
	//strHour =  (self.hasLeadingZerosSwitch.isOn) ? @"hh" : @"h";
	switch (self.timeStyleSegmentedControl.selectedSegmentIndex) {
		case 0:
			// None
			strTime = @"";
			break;
		case 1:
			// Regular
			strTime = [NSString stringWithFormat:@"h:mm a"];
			strTime = @"h:mm a";
			break;
		case 2:
			// Military
			//strHour =  (self.hasLeadingZerosSwitch.isOn) ? @"HH" : @"H";
			//strTime = [NSString stringWithFormat:@"%@:mm",strHour];
			strTime = @"HH:mm";
			break;
		default:
			break;
	}
	switch (self.dateStyleSegmentedControl.selectedSegmentIndex) {
		case 0:
			// Western
			strDate = [NSString stringWithFormat:@"%@%@%@%@%@",
						 strMonth,strSeparator,strDay,strSeparator,strYear];
			break;
		case 1:
			// European
			strDate = [NSString stringWithFormat:@"%@%@%@%@%@",
					   strDay,strSeparator,strMonth,strSeparator,strYear];
			break;
		case 2:
			// Military
					   strDate = [NSString stringWithFormat:@"%@ MMM %@",strDay,strYear];
			break;
		default:
			break;
	}

	strFormat = [NSString stringWithFormat:@"%@%@ %@", strWeekday, strDate, strTime];

	//NSString *localFormatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0															  locale:[NSLocale currentLocale]];
	_strDateTimeFormat = strFormat;

	NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLog(@"DateTime Format: %@", _strDateTimeFormat);
    [formatter setDateFormat:_strDateTimeFormat];
    self.dateTimeLabel.text = [formatter stringFromDate:now];
}

-(void)valueChanged:(id)sender
{
//    if (sender == self.ageSlider) {
//        [[NSUserDefaults standardUserDefaults] setInteger:(int)self.ageSlider.value forKey:kMUAgeMaxKey];
//        self.ageLabel.text = [NSString stringWithFormat:@"%i",(int)self.ageSlider.value];
//    }
//    else
	if (sender == self.showWeekdaySwitch){
        [[NSUserDefaults standardUserDefaults] setInteger:self.showWeekdaySwitch.isOn forKey:@"showWeekday"];
    }else if (sender == self.isFullYearSwitch){
        [[NSUserDefaults standardUserDefaults] setInteger:self.isFullYearSwitch.isOn forKey:@"isFullYear"];
    }
    else if (sender == self.hasLeadingZerosSwitch){
        [[NSUserDefaults standardUserDefaults] setInteger:self.hasLeadingZerosSwitch.isOn forKey:@"hasLeadingZeros"];
    }
    else if (sender == self.dateStyleSegmentedControl){
		if (self.dateStyleSegmentedControl.selectedSegmentIndex == 0) {
			[[NSUserDefaults standardUserDefaults] setObject:@"Western" forKey:@"dateStyle"];
		} else if (self.dateStyleSegmentedControl.selectedSegmentIndex == 1) {
			[[NSUserDefaults standardUserDefaults] setObject:@"European" forKey:@"dateStyle"];
		} else if (self.dateStyleSegmentedControl.selectedSegmentIndex == 2) {
			[[NSUserDefaults standardUserDefaults] setObject:@"Military" forKey:@"dateStyle"];
		}
	}
    else if (sender == self.timeStyleSegmentedControl){
		if (self.timeStyleSegmentedControl.selectedSegmentIndex == 0) {
			[[NSUserDefaults standardUserDefaults] setObject:@"None" forKey:@"timeStyle"];
		} else if (self.timeStyleSegmentedControl.selectedSegmentIndex == 1) {
			[[NSUserDefaults standardUserDefaults] setObject:@"Regular" forKey:@"timeStyle"];
		} else if (self.timeStyleSegmentedControl.selectedSegmentIndex == 2) {
			[[NSUserDefaults standardUserDefaults] setObject:@"Military" forKey:@"timeStyle"];
		}
	}
    else if (sender == self.minutesBeforeDueTextField){
        [[NSUserDefaults standardUserDefaults] setInteger:[self.minutesBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInMinutes"];
    }

    else if (sender == self.hoursBeforeDueTextField){
        [[NSUserDefaults standardUserDefaults] setInteger:[self.hoursBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInHours"];
    }

    else if (sender == self.daysBeforeDueTextField){
        [[NSUserDefaults standardUserDefaults] setInteger:[self.daysBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInDays"];
		NSLog(@"Changed Days: %i", [self.daysBeforeDueTextField.text intValue]);
    }

	[self generateDateTimeFormatString];
	[[NSUserDefaults standardUserDefaults] setObject:_strDateTimeFormat forKey:@"dateTimeFormatString"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 1) {
		[[NSUserDefaults standardUserDefaults] setInteger:[self.minutesBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInMinutes"];
	}

	if (textField.tag == 2) {
		[[NSUserDefaults standardUserDefaults] setInteger:[self.hoursBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInHours"];
	}

	if (textField.tag == 3) {
		[[NSUserDefaults standardUserDefaults] setInteger:[self.daysBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInDays"];
	}

//	if ([textField isEqual:self.hoursBeforeDueTextField]) {
//		[[NSUserDefaults standardUserDefaults] setInteger:[self.hoursBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInHours"];
//	}
//
//	if ([textField isEqual:self.daysBeforeDueTextField]) {
//		[[NSUserDefaults standardUserDefaults] setInteger:[self.daysBeforeDueTextField.text intValue] forKey:@"timeBeforeDueInDays"];
//	}
    [textField resignFirstResponder];
}

-(void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
	// do the following for all textfields in your current view
	[self.daysBeforeDueTextField resignFirstResponder];
	[self.minutesBeforeDueTextField resignFirstResponder];
	[self.hoursBeforeDueTextField resignFirstResponder];
	// save the value of the textfield, ...
}

@end
