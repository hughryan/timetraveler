//
//  HelloWorldAppDelegate.h
//  HelloWorld
//
//  Created by Hugh McDonald on 1/18/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelloWorldAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
