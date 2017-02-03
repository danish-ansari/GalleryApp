//
//  AppDelegate.h
//  GalleryApp
//
//  Created by Raees Shaikh on 03/02/17.
//  Copyright © 2017 Danish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

-(NSManagedObjectContext *) getManagedObjecContext;

@end

