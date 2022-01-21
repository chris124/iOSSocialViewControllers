/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "iOSSServicesViewController.h"
#import "iOSServicesDataSource.h"
#import "iOSSocialServicesStore.h"
#import "iOSSocialLocalUser.h"

@interface iOSSServicesViewController () {
    UITableView *_tableView;
}

@property(nonatomic, retain)    UITableView *tableView;
@property(nonatomic, copy)      ServicesViewControllerHandler servicesViewControllerHandler;
@property(nonatomic, copy)      ServiceConnectedHandler serviceConnectedHandler;
@property(nonatomic, copy)      AccountHandler accountHandler;
@property(nonatomic, retain)    NSMutableArray *services;
@property(nonatomic, retain)    iOSServicesDataSource *servicesDataSource;
@property(nonatomic, retain)    UIActivityIndicatorView *activityView;

@end

@implementation iOSSServicesViewController

@synthesize tableView = _tableView;
@synthesize servicesViewControllerHandler;
@synthesize serviceConnectedHandler;
@synthesize accountHandler;
@synthesize services;
@synthesize servicesDataSource;
@synthesize activityView;

- (id)init
{
    self = [super init];
    if (self) {
        self.services = [iOSSocialServicesStore sharedServiceStore].services;
        
        // Custom initialization
        self.servicesDataSource = [[iOSServicesDataSource alloc] initWithServicesFilter:self.services];
        self.servicesDataSource.displayDoneButton = YES;
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self.servicesDataSource;
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
        activityView.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
        [self.view addSubview: activityView];
    }
    return self;
}

- (id)initWithServicesFilter:(NSArray*)filter
{
    self = [super init];
    if (self) {
        if (filter) {
            self.services = [NSMutableArray array];
            
            //filter out the services based on the filter
            for (id<iOSSocialServiceProtocol> service in [iOSSocialServicesStore sharedServiceStore].services) {
                if ([filter containsObject:service.name]) {
                    [self.services addObject:service];
                }
            }
        } else {
            self.services = [iOSSocialServicesStore sharedServiceStore].services;
        }
        
        // Custom initialization
        self.servicesDataSource = [[iOSServicesDataSource alloc] initWithServicesFilter:self.services];
        self.servicesDataSource.displayDoneButton = YES;
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self.servicesDataSource;
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
        activityView.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
        [self.view addSubview: activityView];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
    self.view = self.tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            case 0:
        {
            id<iOSSocialLocalUserProtocol> localUser = [[iOSSocialServicesStore sharedServiceStore].accounts objectAtIndex:[indexPath row]];
            
            if (self.accountHandler) {
                self.accountHandler(localUser);
            }
        }
            break;
        case 1:
        {
            //cwnote: get back a service object here. need to then get a local user object for the service and authorize that bad boy? 
            //local user object factory that takes a service object? hmmm
            
            id<iOSSocialServiceProtocol> service = [self.services objectAtIndex:[indexPath row]];
            
            id<iOSSocialLocalUserProtocol> localUser = [service localUser];
            
            [self.activityView startAnimating];
            [localUser authenticateFromViewController:self 
                                withCompletionHandler:^(NSError *error){
                                    [self.activityView stopAnimating];
                                    if (!error) {
                                        //let the handler handle it and decice what they want to do this this local user
                                        if (self.serviceConnectedHandler) {
                                            self.serviceConnectedHandler(localUser);
                                        }
                                    } else {
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error was encountered while attempting to retrieve you account information. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                        alertView.alertViewStyle = UIAlertViewStyleDefault;
                                        [alertView show];
                                    }
                                }];
        }
            break;
        case 2:
        {
            if (self.servicesViewControllerHandler) {
                self.servicesViewControllerHandler();
                self.servicesViewControllerHandler = nil; 
                self.serviceConnectedHandler = nil;
                self.accountHandler = nil;
            }
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cwnote: need to make this dynamic some how
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        return 100.0f;
    }
    
    return 75.0f;
}

- (void)refreshUI
{
    [self.tableView reloadData];
}

- (void)presentModallyFromViewController:(UIViewController*)vc 
                      withAccountHandler:(AccountHandler)theAccountHandler 
             withServiceConnectedHandler:(ServiceConnectedHandler)newServiceConnectionHandler 
                   withCompletionHandler:(ServicesViewControllerHandler)completionHandler
{
    self.accountHandler = theAccountHandler;
    self.serviceConnectedHandler = newServiceConnectionHandler;
    self.servicesViewControllerHandler = completionHandler;
    
    [vc presentModalViewController:self animated:YES];
}

@end
iOSSocialViewControllers/Classes/iOSSServicesViewController.m
