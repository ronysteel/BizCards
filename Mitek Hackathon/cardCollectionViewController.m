//
//  cardCollectionViewController.m
//  Mitek Hackathon
//
//  Created by Zaid Elkurdi on 4/25/14.
//  Copyright (c) 2014 Tempest Vision. All rights reserved.
//

#import "cardCollectionViewController.h"

@interface cardCollectionViewController ()
{
    NSIndexPath *currEditingIndex;
    NSMutableData *webdata;
}
@end

@implementation cardCollectionViewController

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
    
    [self makeRequest];
    
    /* Init Nav Bar */
    UIColor *barColor = [UIColor colorWithRed:29.0f/255.0f green:143.0f/255.0f blue:102.0f/255.0f alpha: 1.0];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 40);
    self.navigationController.navigationBar.barTintColor=barColor;
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    navTitle.text = @"Your Cards";
    navTitle.textColor = [UIColor whiteColor];
    UIFont *navFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
    navTitle.font = navFont;
    navTitle.textAlignment = NSTextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:navTitle];
    
    /* Init Table */
    CGRect tableFrame = CGRectMake(20, 40, 280, self.view.frame.size.height-40);
    self.cardCollectionTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    
    self.cardCollectionTable.delegate = self;
    self.cardCollectionTable.dataSource = self;
    
    UIColor *tableBGColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:219.0f/255.0f alpha: 1.0];
    self.cardCollectionTable.backgroundColor = tableBGColor;
    
    [self.view addSubview:self.cardCollectionTable];
    [self setNeedsStatusBarAppearanceUpdate];
    
    /* Init Table Data */
    self.cardData = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    
    /* Init Table Swipe */
    UISwipeGestureRecognizer * swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(confirmDelete:)];
    [swipeRecognizer setDelegate:self];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.cardCollectionTable addGestureRecognizer:swipeRecognizer];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{ 
    return UIStatusBarStyleLightContent; 
}

-(void)makeRequest
{
    NSDictionary *headerFieldsDict = [NSDictionary
                                      dictionaryWithObjectsAndKeys:@"Apple iPhone",@"User-Agent",
                                      @"text/xml; charset=utf-8", @"Content-Type",
                                      @"soapAction",@"SOAP_ACTION",nil];
    
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"authenticate" ofType:@"xml"];
    NSLog(@"%@", xmlPath);
    
    NSError *error;
    NSString *xmlString = [NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error with XML conversion: %@", [error description]);
    }
    else {
        NSLog(@"XML Data: %@", xmlString);
    }
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://mip03.ddc.mitekmobile.com/MobileImagingPlatformWebServices/ImagingPhoneService.asmx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setAllHTTPHeaderFields:headerFieldsDict];
    [theRequest setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Connection error: %@", [connectionError description]);
        }
        else {
            
            NSString* theString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Success : %@", [response description]);
            NSLog(@"Data: %@", theString);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.cardData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cardCollectionCellIdentifier";
    cardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil)
    {
        cell = [[cardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.cardImageView setImage:[UIImage imageNamed:@"testCard.png"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section != 0)
        return 1;
    
    return 30;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - Other methods
-(void)confirmDelete:(UIGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeLocation = [recognizer locationInView:self.cardCollectionTable];
        currEditingIndex = [self.cardCollectionTable indexPathForRowAtPoint:swipeLocation];
//        cardCell *swipedCell =
//                (cardCell*)[self.cardCollectionTable cellForRowAtIndexPath:swipedIndexPath];

        UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this card?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [deleteAlert show];
    
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        [self.cardData removeObjectAtIndex:currEditingIndex.section];
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:currEditingIndex.section];
        [self.cardCollectionTable beginUpdates];
        [self.cardCollectionTable deleteSections:set withRowAnimation:UITableViewRowAnimationLeft];
        [self.cardCollectionTable endUpdates];
    }
    
    [alertView dismissWithClickedButtonIndex:1 animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
