//
//  AppDelegate.m
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "BookmarksViewController.h"
#import "Movie.h"
#import <CoreData/CoreData.h>

NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";

@interface AppDelegate () <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation AppDelegate {
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [NSFetchedResultsController deleteCacheWithName:@"Movies"];
    [self getBookmarks];
    
    UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
    
    [[UITabBar appearance] setTintColor:[UIColor purpleColor]];
    [[UIAlertView appearance] setTintColor:[UIColor purpleColor]];
    
    UINavigationController *firstNavigationController = (UINavigationController*)tabBarController.viewControllers[0];
    SearchViewController *searchViewController = (SearchViewController*)firstNavigationController.viewControllers[0];
    searchViewController.managedObjectContext = self.managedObjectContext;
    searchViewController.fetchedResultsController = self.fetchedResultsController;
    
    UINavigationController *secondNavigationController = (UINavigationController*)tabBarController.viewControllers[1];
    BookmarksViewController *bookmarksViewController = (BookmarksViewController*)secondNavigationController.viewControllers[0];
    bookmarksViewController.managedObjectContext = self.managedObjectContext;
    bookmarksViewController.fetchedResultsController = self.fetchedResultsController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fatalCoreDataError:) name:ManagedObjectContextSaveDidFailNotification object:nil];

    return YES;
}

-(NSFetchedResultsController*)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"movieTitle" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Movies"];
        
        _fetchedResultsController.delegate = self;
        
    }
    
    return _fetchedResultsController;
}

-(void)fatalCoreDataError:(NSNotification*)notification {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internal error" message:@"There was a fatal error in the app and it cannot continue.\n\nPress OK to terminate the app. Sorry for inconvenience." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
}

-(void)getBookmarks {
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data

-(NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel == nil) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

-(NSString*)documentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return documentsDirectory;
    
}

-(NSString*)dataStorePath {
    
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
    
}

-(NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator == nil) {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error adding persistent store %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
    
}

-(NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    
    return _managedObjectContext;
    
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    abort();
    
}

#pragma mark - NSFetchedResultsControllerDelegate 

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    
}


@end
