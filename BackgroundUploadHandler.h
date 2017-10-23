//
//  BackgroundUploadImageHandler.h
//  UpdloadInBackground
//
//  Created by Sajad on 10/11/17.
//  Copyright © 2017 TPLHolding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundUploadHandler : NSObject
/**
 Create and start an upload task with background configration
 @param fileURL URL for local file which is to be uploaded
 @param uploadURL Server URL where files will be uploaded
 @param mimeType Mime Type of the files being uploaded e.g image/png
 @param completionHandler Called when upload is complete, if failed then error object passed in this block contains the resons of failure.
 @param responseHandler Called when receive some response from server
 @param progress Called with updated upload progress
 @return A NSURLSessionUploadTask for the file to be uploaded.
 */
- (NSURLSessionUploadTask *)beginBackgroundUploadTaskWithFile:(NSURL *)fileURL
                                                    uploadURL:(NSURL *)uploadURL
                                                     mimeType:(NSString *)mimeType
                                            completionHandler:(void (^)(NSError *error))completionHandler
                                              responseHandler:(void (^)(NSData *responseData))responseHandler
                                                     progress:(void (^)(NSProgress *progress))progress;

/**
 Create and start an upload task with background configration
 @param fileURL URL for local file which is to be uploaded
 @param uploadURL Server URL where files will be uploaded
 @param completionHandler Called when upload is complete, if failed then error object passed in this block contains the resons of failure.
 @param responseHandler Called when receive some response from server
 @param progress Called with updated upload progress
 @return A NSURLSessionUploadTask for the file to be uploaded.
 */

- (NSURLSessionUploadTask *)beginBackgroundUploadTaskWithFile:(NSURL *)fileURL
                                                    uploadURL:(NSURL *)uploadURL
                                            completionHandler:(void (^)(NSError *error))completionHandler
                                              responseHandler:(void (^)(NSData *responseData))responseHandler
                                                     progress:(void (^)(NSProgress *progress))progress;

/**
 Block for notifying when all of the background tasks are done. Called from NSURLSessionDelegate method URLSessionDidFinishEventsForBackgroundURLSession:, you need to call completion handler recieved in AppDelegate method application:handleEventsForBackgroundURLSession:completionHandler: with in this block to let system know that you are done with uploading.
 */
                   
@property (nonatomic, copy) void (^didFinishEventsForBackgroundURLSessionBlock)(NSURLSession *);
@end
