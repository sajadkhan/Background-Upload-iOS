//
//  BackgroundUploadImageHandler.m
//  UpdloadInBackground
//
//  Created by Sajad on 10/11/17.
//  Copyright © 2017 TPLHolding. All rights reserved.
//

#import "BackgroundUploadHandler.h"
@interface BackgroundUploadHandler() <NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, copy) void (^taskCompletionBlock)(NSError *);
@property (nonatomic, copy) void (^taskResponseBlock)(NSData *);
@property (nonatomic, copy) void (^taskProgressBlock)(NSProgress *);

@end

@implementation BackgroundUploadHandler

- (NSURLSession *)backgroundSession
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:appID];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}


- (NSURLSessionUploadTask *)beginBackgroundUploadTaskWithFile:(NSURL *)fileURL
                                                    uploadURL:(NSURL *)uploadURL
                                                     mimeType:(NSString *)mimeType
                                            completionHandler:(void (^)(NSError *))completionHandler
                                              responseHandler:(void (^)(NSData *))responseHandler
                                                     progress:(void (^)(NSProgress *))progress  {
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:uploadURL];
    [mutableRequest setHTTPMethod:@"POST"];
    if (mimeType)
        [mutableRequest setValue:mimeType forHTTPHeaderField:@"Content-Type"];
    
    self.taskCompletionBlock = completionHandler;
    self.taskResponseBlock = responseHandler;
    self.taskProgressBlock = progress;
    
    NSURLSession *session = [self backgroundSession];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:mutableRequest fromFile:fileURL];
    [task resume];
    return task;
}

- (NSURLSessionUploadTask *)beginBackgroundUploadTaskWithFile:(NSURL *)fileURL
                                                    uploadURL:(NSURL *)uploadURL
                                            completionHandler:(void (^)(NSError *))completionHandler
                                              responseHandler:(void (^)(NSData *))responseHandler
                                                     progress:(void (^)(NSProgress *))progress {
    return [self beginBackgroundUploadTaskWithFile:fileURL
                                         uploadURL:uploadURL
                                          mimeType:nil
                                 completionHandler:completionHandler
                                   responseHandler:responseHandler progress:progress];
}

#pragma mark - URLSession Delegates

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.taskResponseBlock)
        self.taskResponseBlock(data);
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.taskCompletionBlock)
        self.taskCompletionBlock(error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSProgress *progress = [[NSProgress alloc] init];
    [progress setTotalUnitCount:totalBytesExpectedToSend];
    [progress setCompletedUnitCount:totalBytesSent];
    if (self.taskProgressBlock)
        self.taskProgressBlock(progress);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.didFinishEventsForBackgroundURLSessionBlock) {
        self.didFinishEventsForBackgroundURLSessionBlock(session);
    }
}


@end
