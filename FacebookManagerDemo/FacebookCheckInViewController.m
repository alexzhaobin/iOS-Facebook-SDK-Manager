//
//  FacebookCheckInViewController.m
//  CrownWestend
//
//  Created by Alex Zhao Bin on 23/05/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import "FacebookCheckInViewController.h"
#import "FacebookManager.h"
#import "CustomTableViewCell.h"
#import "SystemWideImageLoader.h"
#import "MultilineTextView.h"

@interface FacebookCheckInViewController()<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL sendRequestAlready;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    UIImage *imagePicked;
    
    UITextView *messageTextView;
    UITableView *placesTableView;
    NSArray *placeIds;
    NSMutableArray *places;
    NSUInteger selectedPlaceIndex;
}

@end

@implementation FacebookCheckInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        sendRequestAlready = NO;
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        placeIds = [NSArray arrayWithObjects:@"193021137410643", @"163999780282569", @"300385710007920", @"123510934373702", nil];
        places = [NSMutableArray array];
        for (NSString *placeId in placeIds) {
            [FacebookManager searchPlaceById:placeId withCompletionHandler:^(id results) {
                [places addObject:results];
                [placesTableView reloadData];
                [placesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedPlaceIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }];
        }
    }
    return self;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if(newLocation.horizontalAccuracy < 100) {
        currentLocation = newLocation;
        
        /*
         if (!sendRequestAlready) {[FacebookManager searchPlaceByCoordinate:newLocation.coordinate withCompletionHandler:^(id results) {
         NSLog(@"%@", results);
         if ([results isKindOfClass:[NSDictionary class]]) {
         places = [(NSArray *)[results objectForKey:@"data"] mutableCopy];
         [placesTableView reloadData];
         }
         }];
         sendRequestAlready = YES;
         }*/
        
        
    }
}

- (void)loadView {
    [super loadView];
    
    CGFloat accumulatedHeight = 0.0;
    CGFloat spaceBetweenElements = 20.0;
    messageTextView = [[MultilineTextView alloc] initWithFrame:CGRectMake(0.0, accumulatedHeight, self.view.bounds.size.width, 100.0)];
    messageTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    messageTextView.font = [UIFont systemFontOfSize:15.0];
    messageTextView.textColor = [UIColor blackColor];
    messageTextView.textAlignment = UITextAlignmentCenter;
    messageTextView.delegate = self;
    [self.view addSubview:messageTextView];
    
    accumulatedHeight = messageTextView.frame.origin.y + messageTextView.frame.size.height + spaceBetweenElements;
    UIButton *checkInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    checkInButton.frame = CGRectMake(self.view.frame.size.width / 2 - 145.0, accumulatedHeight, 90.0, 30.0);
    checkInButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [checkInButton setTitle:@"Check In" forState:UIControlStateNormal];
    [checkInButton addTarget:self action:@selector(checkInToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkInButton];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    dismissButton.frame = CGRectMake(self.view.frame.size.width / 2 - 45.0, accumulatedHeight, 90.0, 30.0);
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissTestView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    photoButton.frame = CGRectMake(self.view.frame.size.width / 2 + 55.0, accumulatedHeight, 90.0, 30.0);
    photoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [photoButton setTitle:@"Photo" forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(choosePicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoButton];
    
    accumulatedHeight = checkInButton.frame.origin.y + checkInButton.frame.size.height + spaceBetweenElements;
    placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, accumulatedHeight, self.view.bounds.size.width, self.view.bounds.size.height - accumulatedHeight) style:UITableViewStyleGrouped];
    placesTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    placesTableView.backgroundColor = [UIColor clearColor];
	placesTableView.separatorColor = [UIColor grayColor];
	placesTableView.delegate = self;
	placesTableView.dataSource = self;
	placesTableView.rowHeight = 44.0;
	[self.view addSubview:placesTableView];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOutFacebook:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)signOutFacebook:(id)sender {
    [FacebookManager logout];
}

- (void)checkInToFacebook:(id)sender {
    if (selectedPlaceIndex < places.count && currentLocation) {
        [FacebookManager checkInToPlace:[[places objectAtIndex:selectedPlaceIndex] objectForKey:@"id"] atCoordinate:currentLocation.coordinate message:messageTextView.text photoURL:nil withCompletionHandler:^(id results) {
            [UIAlertView showAlert:[NSString stringWithFormat:@"You have checked in %@", [[places objectAtIndex:selectedPlaceIndex] objectForKey:@"name"]] title:@"Check In Successfully"];
        }];
    } else {
        [UIAlertView showAlert:@"No placed selected or can't determin current location" title:@"Unable to check in"];
    }
}

- (void)dismissTestView:(id)sender {
    [messageTextView resignFirstResponder];
}

- (void)choosePicture:(id)sender
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[imagePicker setDelegate:self];
	[self presentModalViewController:imagePicker animated:YES];
}

#pragma -
#pragma UIImagePickerControllerDelegate Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//Get image
	imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    
	//Take image picker off the screen (required)
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
	return places.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PrizesListTableCellIdentifierSingle = @"PrizesListTableCellIdentifierSingle";
    static NSString *PrizesListTableCellIdentifierTop = @"PrizesListTableCellIdentifierTop";
    static NSString *PrizesListTableCellIdentifierBottom = @"PrizesListTableCellIdentifierBottom";
    static NSString *PrizesListTableCellIdentifierMiddle = @"PrizesListTableCellIdentifierMiddle";
    
    NSString *reuseIdentifier = nil;
    CustomTableViewCellBackgroundViewPosition backgroundViewPosition;
    
    if (places.count == 1) {
        reuseIdentifier = PrizesListTableCellIdentifierSingle;
        backgroundViewPosition = CustomTableViewCellBackgroundViewPositionSingle;
    } else if (indexPath.row == 0) {
        reuseIdentifier = PrizesListTableCellIdentifierTop;
        backgroundViewPosition = CustomTableViewCellBackgroundViewPositionTop;
    } else if (places.count == indexPath.row + 1) {
        reuseIdentifier = PrizesListTableCellIdentifierBottom;
        backgroundViewPosition = CustomTableViewCellBackgroundViewPositionBottom;
    } else {
        reuseIdentifier = PrizesListTableCellIdentifierMiddle;
        backgroundViewPosition = CustomTableViewCellBackgroundViewPositionMiddle;
    }
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[placesTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [cell.detailButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents: UIControlEventTouchUpInside];
    }
    cell.position = backgroundViewPosition;
	NSDictionary *friend = [places objectAtIndex:indexPath.row];
    cell.textLabel.text = [friend objectForKey:@"name"];
    
    [SystemWideImageLoader loadImageForFacebookObject:[friend objectForKey:@"id"] withCompletionHandler:^(UIImage *facebookImage) {
        
        cell.imageView.image = facebookImage;
        
    } withFailureHandler:^(NSError *error) {
        
    }];
    
	return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath * indexPath = [placesTableView indexPathForRowAtPoint:[[[event touchesForView: button] anyObject] locationInView:placesTableView]];
    if ( indexPath == nil )
        return;
    
    [placesTableView.delegate tableView:placesTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPlaceIndex = indexPath.row;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	return YES;
}

@end
