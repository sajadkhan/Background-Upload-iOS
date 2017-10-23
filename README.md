# Background-Upload
Little helper class for uploading files in background in iOS.

Uses NSURLSession from foundation framework to upload files in background. If you want to know in detail how it works here is [URLSession Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html )


```Objective-C
- (void)uploadUsingURLSession:(NSURL *)fileURL {
    if (!self.backgroundUploadImageHandler)
        self.backgroundUploadImageHandler = [[BackgroundUploadHandler alloc] init];
    
    [self.backgroundUploadImageHandler beginBackgroundUploadTaskWithFile:fileURL
                                                               uploadURL:[NSURL URLWithString:uploadURLString]
                                                                mimeType:@"image/jpeg"
                                                       completionHandler:^(NSError *error) {
                                                          // Handle Error here
                                                       } responseHandler:^(NSData *responseData) {
                                                          // Handle Response from server
                                                       } progress:^(NSProgress *progress) {
                                                           NSLog(@"Progress = %.2f", progress.fractionCompleted);
                                                           // Progress of upload
                                                       }];
    
    self.backgroundUploadImageHandler.didFinishEventsForBackgroundURLSessionBlock = ^(NSURLSession *session) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            void(^completionHandler)(void) = appDelegate.backgroundSessionCompletionHandler;
            appDelegate.backgroundSessionCompletionHandler = nil;
            completionHandler();
        }
        
    };
}
```

In **AppDelegate.h** Declare this property 
```Objective-C
@property (copy) void (^backgroundSessionCompletionHandler)(void);
```

In **AppDelegate.m** Implement this 
```Objective-C
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    self.backgroundSessionCompletionHandler = completionHandler;
}
```
