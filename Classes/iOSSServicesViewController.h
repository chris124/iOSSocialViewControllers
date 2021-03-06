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
