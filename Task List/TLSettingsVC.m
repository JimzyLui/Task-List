//
//  TLSettingsVC.m
//  Task List
//
//  Created by Jimzy Lui on 1/25/2014.
//  Copyright (c) 2014 Jimzy Lui. All rights reserved.
//

#import "TLSettingsVC.h"

@interface TLSettingsVC ()<UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *showWeekdaySwitch;
@property (strong, nonatomic) IBOutlet UISwitch *isFullYearSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *hasLeadingZerosSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timeStyleSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *dateStyleSegmentedControl;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;


@property(nonatomic)NSInteger iWeeks;
@property(nonatomic)NSInteger iDays;
@property(nonatomic)NSInteger iHours;
@property(nonatomic)NSInteger iMinutes;
@property(strong,nonatomic)NSString *strDateTimeFormat;

@property(strong,nonatomic)NSMutableArray *Weeks;
@property(strong,nonatomic)NSMutableArray *Days;
@property(strong,nonatomic)NSMutableArray *Hours;
@property(strong,nonatomic)NSMutableArray *Minutes;


@end

@implementation TLSettingsVC

#pragma mark - Lazy Instantiation

-(NSMutableArray *)Weeks
{
    if(!_Weeks){
        _Weeks = [[NSMutableArray alloc] init];
    }
    return _Weeks;
}


-(NSMutableArray *)Days
{
    if(!_Days){
        _Days = [[NSMutableArray alloc] init];
    }
    return _Days;
}


-(NSMutableArray *)Hours
{
    if(!_Hours){
        _Hours = [[NSMutableArray alloc] init];
    }
    return _Hours;
}


-(NSMutableArray *)Minutes
{
    if(!_Minutes){
        _Minutes = [[NSMutableArray alloc] init];
    }
    return _Minutes;
}

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

	self.scrollView.delegate = self;
	self.pickerView.delegate = self;
	self.pickerView.dataSource = self;

	//set up arrays
	[self setupPickerDataArrays];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.automaticallyAdjustsScrollViewInsets = NO;

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
	self.iHours = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInHours"];
	self.iDays = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInDays"];
	self.iWeeks = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeBeforeDueInWeeks"];


	NSLog(@"pickerView: Weeks: %ld/%ld  Days: %ld/%ld  Hours: %ld/%ld Minutes: %ld/%ld (%ld/%ld) ",
		  (long)self.iWeeks,(long)self.Weeks.count,
		  (long)self.iDays,(long)self.Days.count,
		  (long)self.iHours,(long)self.Hours.count,
		  (long)self.iMinutes * 5,(long)self.Minutes.count * 5,
		  (long)self.iMinutes,(long)self.Minutes.count
		  );
	//[self.pickerView selectRow:0 inComponent:0 animated:NO];
	[self.pickerView selectRow:self.iWeeks inComponent:0 animated:YES];
	[self.pickerView selectRow:self.iDays inComponent:1 animated:YES];
	[self.pickerView selectRow:_iHours inComponent:2 animated:YES];
	[self.pickerView selectRow:_iMinutes inComponent:3 animated:YES];
	[self.pickerView reloadAllComponents];

	_strDateTimeFormat = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateTimeFormatString"];

	[self generateDateTimeFormatString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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

	//Weeks
	self.iWeeks = [_pickerView selectedRowInComponent:0];
	[[NSUserDefaults standardUserDefaults] setInteger:self.iWeeks forKey:@"timeBeforeDueInWeeks"];
	NSLog(@"iWeeks saved: %ld",(long)self.iWeeks );
	//Days
	self.iDays = [_pickerView selectedRowInComponent:1];
	[[NSUserDefaults standardUserDefaults] setInteger:self.iDays forKey:@"timeBeforeDueInDays"];
	//Hours
	self.iHours = [_pickerView selectedRowInComponent:2];
	[[NSUserDefaults standardUserDefaults] setInteger:self.iHours forKey:@"timeBeforeDueInHours"];
	//Minutes
	self.iMinutes = [_pickerView selectedRowInComponent:3];
	[[NSUserDefaults standardUserDefaults] setInteger:self.iMinutes forKey:@"timeBeforeDueInMinutes"];

	[self generateDateTimeFormatString];
	[[NSUserDefaults standardUserDefaults] setObject:_strDateTimeFormat forKey:@"dateTimeFormatString"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - Delegate Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return [self.Weeks count];
			break;
		case 1:
			return [self.Days count];
			break;
		case 2:
			return [self.Hours count];
			break;
		case 3:
			return [self.Minutes count];
			break;

		default:
			return 0;
			break;
	}
}




-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return [NSString stringWithFormat:@"%@",[self.Weeks objectAtIndex:row]];
			//return [self.Weeks objectAtIndex:row];
			//return @"I love you!";

			break;
		case 1:
			//return @"I love you!";
			return [NSString stringWithFormat:@"%@",[self.Days objectAtIndex:row]];
			break;
		case 2:
			//return @"I love you!";
			return [NSString stringWithFormat:@"%@",[self.Hours objectAtIndex:row]];
			break;
		case 3:
			//return @"I love you!";

			return [NSString stringWithFormat:@"%@",self.Minutes[row]];
			//return [_Minutes objectAtIndex:row];
			break;

		default:
			return 0;
			break;
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

	switch (component) {
		case 0:
			//Weeks
			//self.iWeeks = (int) self.Weeks[row];
			self.iWeeks = [_pickerView selectedRowInComponent:0];
			[[NSUserDefaults standardUserDefaults] setInteger:self.iWeeks forKey:@"timeBeforeDueInWeeks"];

			break;
		case 1:
			//Days
			//self.iDays = (int) self.Days[row];
			self.iDays = [_pickerView selectedRowInComponent:1];
			[[NSUserDefaults standardUserDefaults] setInteger:self.iDays forKey:@"timeBeforeDueInDays"];
			break;
		case 2:
			//Hours
			//self.iHours = (int) self.Hours[row];
			self.iHours = [_pickerView selectedRowInComponent:2];
			[[NSUserDefaults standardUserDefaults] setInteger:self.iHours forKey:@"timeBeforeDueInHours"];
			break;
		case 3:
			//Minutes
			//self.iMinutes = (int) self.Minutes[row];
			self.iMinutes = [_pickerView selectedRowInComponent:3];
			[[NSUserDefaults standardUserDefaults] setInteger:self.iMinutes forKey:@"timeBeforeDueInMinutes"];
			break;

		default:
			break;
	}

}

-(void)setupPickerDataArrays
{
	//self.Weeks = [[NSMutableArray alloc] init];
	for (NSInteger weeks = 0; weeks < 52; weeks++) {
		//NSLog(@"%ld, count: %ld",(long)weeks, self.Weeks.count);
		[self.Weeks addObject:[NSNumber numberWithInteger:weeks]];
	}

	//self.Days = [[NSMutableArray alloc] init];
	for (NSInteger days = 0; days < 7; days++) {
		//NSLog(@"%ld, count: %ld",(long)days, self.Days.count);
		[self.Days addObject:[NSNumber numberWithInteger:days]];
	}

	//self.Hours = [[NSMutableArray alloc] init];
	for (NSInteger hours = 0; hours < 24; hours++) {
		[self.Hours addObject:[NSNumber numberWithInteger:hours]];
	}

	//self.Minutes = [[NSMutableArray alloc] init];
	for (NSInteger minutes = 0; minutes < 60; minutes+=5) {
		[self.Minutes addObject:[NSNumber numberWithInteger:minutes]];
	}
	//NSLog(@"setupPickerDataArrays: Days: %lu",(unsigned long)self.Days.count);
}

@end
