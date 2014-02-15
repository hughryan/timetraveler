//
//  TimeTravelerAppDelegate.h
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/2/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTravelerAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator ;

@property (strong, nonatomic) UIWindow *window;

@end
