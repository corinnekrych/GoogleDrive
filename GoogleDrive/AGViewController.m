//
//  AGViewController.m
//  GoogleDrive
//
//  Created by Corinne Krych on 12/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGViewController.h"
#import "AeroGear.h"
#import "AFHTTPClient.h"

@interface AGViewController ()

@end

@implementation AGViewController {
    id<AGAuthzModule> _restAuthzModule;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)authorize:(UIButton *)sender {
    AGAuthorizer* authorizer = [AGAuthorizer authorizer];
    
    _restAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] initWithString:@"https://accounts.google.com"];
        config.authzEndpoint = @"/o/oauth2/auth";
        config.accessTokenEndpoint = @"/o/oauth2/token";
        config.clientId = @"241956090675-gkeh47arq23mdise57kf3abecte7i5km.apps.googleusercontent.com";
        config.redirectURL = @"org.aerogear.GoogleDrive:/oauth2Callback";
        config.scopes = @[@"https://www.googleapis.com/auth/drive"];
    }];
    
    [_restAuthzModule requestAccess:nil success:^(id object) {
        NSLog(@"SUCCESS!!!");
        
        
        
        NSString* readGoogleDriveURL = @"https://www.googleapis.com/drive/v2/files";
        
        NSString *url = [NSString stringWithFormat:@"%@?access_token=%@", readGoogleDriveURL, object];
        
        AFHTTPClient* restClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:readGoogleDriveURL]];
        
        [restClient postPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
              NSLog(@"Invoking successblock for List Google DRIVE....");

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                NSLog(@"Invoking failure block DRIVE....");

        }];
        
    } failure:^(NSError *error) {
        NSLog(@"FAILED!!!");
    }];
}

@end
