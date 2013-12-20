/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGViewController.h"
#import "AeroGear.h"
#import "AFHTTPClient.h"

@interface AGViewController ()

@end

@implementation AGViewController {
    id<AGAuthzModule> _restAuthzModule;
    NSMutableArray* _documents;
}
@synthesize documents = _documents;
@synthesize tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_documents count];
}
- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DocumentCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[_documents objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize pop-up warning to start OAuth2 authz
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Authorize GoogleDrive" message:@"Do you want to authorize GoogleDrive to access your Google Drive data? You will be redirected to Google login to authenticate and grant access." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self authorize:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        [self fetchGoogleDriveDocuments:object];
    } failure:^(NSError *error) {
    }];
}

-(void)fetchGoogleDriveDocuments:(NSString*) code {
    NSString* readGoogleDriveURL = @"https://www.googleapis.com/drive/v2/files";
    NSString *url = [NSString stringWithFormat:@"%@?access_token=%@", readGoogleDriveURL, code];
    
    AFHTTPClient* restClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:readGoogleDriveURL]];
    //TODO integrate with pipe
    [restClient getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _documents = [[self buildDocumentList:responseObject] copy];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Invoking failure block DRIVE....");
    }];

}

-(NSArray*)buildDocumentList:(NSData*)data {
    NSMutableArray* list = [NSMutableArray array];
    NSString* responseJSON = [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];

    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableLeaves
                                                           error:nil];

    for (NSDictionary *item in JSON[@"items"]) {
        if(![item[@"title"] isEqualToString:@"Untitled"]) {
            [list addObject:item];
        }
    }
    return [list copy];
}
@end
