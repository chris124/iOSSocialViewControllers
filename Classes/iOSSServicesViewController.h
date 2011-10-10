//
//  iOSSServicesViewController.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol iOSSocialLocalUserProtocol;

typedef void(^ServicesViewControllerHandler)();
typedef void(^ServiceConnectedHandler)(id<iOSSocialLocalUserProtocol> localUser);
typedef void(^AccountHandler)(id<iOSSocialLocalUserProtocol> localUser);

@interface iOSSServicesViewController : UIViewController <UITableViewDelegate> {
}

- (id)initWithServicesFilter:(NSArray*)filter;

- (void)refreshUI;

- (void)presentModallyFromViewController:(UIViewController*)vc 
                      withAccountHandler:(AccountHandler)serviceConnectedHandler 
             withServiceConnectedHandler:(ServiceConnectedHandler)serviceConnectedHandler 
                   withCompletionHandler:(ServicesViewControllerHandler)completionHandler;

@end
