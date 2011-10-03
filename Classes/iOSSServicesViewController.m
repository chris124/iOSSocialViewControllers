//
//  iOSSServicesViewController.m
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

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
@property(nonatomic, retain)    NSMutableArray *services;
@property(nonatomic, retain)    iOSServicesDataSource *servicesDataSource;

@end

@implementation iOSSServicesViewController

@synthesize tableView = _tableView;
@synthesize servicesViewControllerHandler;
@synthesize serviceConnectedHandler;
@synthesize services;
@synthesize servicesDataSource;

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

            if ([localUser isAuthenticated]) {
                [localUser logout];
                [self refreshUI];
            } else {
                [localUser authenticateFromViewController:self 
                                    withCompletionHandler:^(NSError *error){
                                        if (!error) {
                                            [self refreshUI];
                                        }
                                    }];
            }
        }
            break;
        case 1:
        {
            //cwnote: get back a service object here. need to then get a local user object for the service and authorize that bad boy? 
            //local user object factory that takes a service object? hmmm
            
            id<iOSSocialServiceProtocol> service = [self.services objectAtIndex:[indexPath row]];
            
            id<iOSSocialLocalUserProtocol> localUser = [service localUser];
            
            [localUser authenticateFromViewController:self 
                                withCompletionHandler:^(NSError *error){
                                    if (!error) {
                                        //let the handler handle it and decice what they want to do this this local user
                                        if (self.serviceConnectedHandler) {
                                            self.serviceConnectedHandler(localUser);
                                        }
                                        [self refreshUI];
                                    }
                                }];
        }
            break;
        case 2:
        {
            if (self.servicesViewControllerHandler) {
                self.servicesViewControllerHandler();
                self.servicesViewControllerHandler = nil; 
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
             withServiceConnectedHandler:(ServiceConnectedHandler)newServiceConnectionHandler 
                   withCompletionHandler:(ServicesViewControllerHandler)completionHandler
{
    self.serviceConnectedHandler = newServiceConnectionHandler;
    self.servicesViewControllerHandler = completionHandler;
    
    [vc presentModalViewController:self animated:YES];
}

@end
