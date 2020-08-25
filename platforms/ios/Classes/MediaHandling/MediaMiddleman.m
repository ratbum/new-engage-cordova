//
//  MediaMiddleman2.m
//  Engage
//
//  Created by Thomas Lee on 20/02/2020.
//

#import "MediaMiddleman.h"
#import <GCDWebServers/GCDWebServers.h>
#import <Sentry/Sentry.h>

@implementation MediaMiddleman

- (instancetype)init {
  self.webServer = [GCDWebServer new];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.cookie = [NSString stringWithFormat:@"filestorage=%@", [[NSUUID new] UUIDString]];
    self.mimeMap = @{
        @"audio/mp3": @".mp3",
        @"audio/m4a": @".m4a",
        @"audio/x-m4a": @".m4a",
        @"audio/vnd.wave": @".wav",
        @"audio/wav": @".wav",
        @"audio/wave": @".wav",
        @"audio/x-wav": @".wav",
        @"video/mp4": @".mp4",
        @"video/ogv": @".ogg",
        @"video/quicktime": @".mov",
        @"image/jpeg": @".jpg",
        @"image/png": @".png",
        @"image/gif": @".gif"
    };
  });
  return self;
}

- (NSString *)userToken {
  NSError *error;
  NSString *userJson = [NSUserDefaults.standardUserDefaults objectForKey:@"UserToken"];
  NSData *userData = [userJson dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingAllowFragments error:&error];
  return userDict[@"access_token"];
}

- (BOOL)isAuthorizedWithHeaders:(NSDictionary *)headers {
  NSString *authHeader = [headers objectForKey:@"Authorization"];
  if (authHeader == nil || [authHeader isEqualToString:@""]) {
    return false;
  }
  NSArray *authParts = [authHeader componentsSeparatedByString:@" "];
  if ([authParts count] == 2) {
    NSString *bearerToken = authParts[1];
    return [[bearerToken lowercaseString] isEqualToString: [[self userToken] lowercaseString]];
  }
  return false;
}

- (BOOL)isAuthorizedWithCookie:(NSDictionary *)headers {
  NSString *cookieHeader = [headers objectForKey:@"Cookie"];
  if (cookieHeader == nil || [cookieHeader isEqualToString:@""]) {
    return false;
  }

  return [[cookieHeader lowercaseString] isEqualToString: [[self cookie] lowercaseString]];
}

- (NSString *)fileExtensionAssociatedWithMimeType:(NSString *)mimeType {
  return [self.mimeMap objectForKey:mimeType];
}

- (NSString *)mediaDirectory {
  const char *documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                                            inDomains: NSUserDomainMask] lastObject] fileSystemRepresentation];
  NSString *docDir = [NSString stringWithCString:documentsDirectory encoding:NSUTF8StringEncoding];
  NSString *mediaDirectory = [docDir stringByAppendingString:@"/media"];
  return mediaDirectory;
}

- (void)setup {
  __weak MediaMiddleman *weakSelf = self;
  NSString *mediaDirectory = [self mediaDirectory];
  NSString *basePath = @"/files/";
  NSString *directoryPath = mediaDirectory;
  NSString *indexFilename = nil;
  NSUInteger cacheAge = 0;
  BOOL allowRangeRequests = YES;
  
  [self.webServer addHandlerWithMatchBlock:^GCDWebServerRequest*(NSString* requestMethod, NSURL* requestURL, NSDictionary<NSString*, NSString*>* requestHeaders, NSString* urlPath, NSDictionary<NSString*, NSString*>* urlQuery) {
    if (![requestMethod isEqualToString:@"GET"]) {
      return nil;
    }
    if (![urlPath hasPrefix:basePath]) {
      return nil;
    }
    if (![weakSelf isAuthorizedWithCookie:requestHeaders]) {
      return nil;
    }
    return [[GCDWebServerRequest alloc] initWithMethod:requestMethod url:requestURL headers:requestHeaders path:urlPath query:urlQuery];
  }
                              processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
    if (![weakSelf isAuthorizedWithCookie:request.headers]) {
      return nil;
    }    
    GCDWebServerResponse *response = nil;
    NSString *filePath = [directoryPath stringByAppendingPathComponent:GCDWebServerNormalizePath([request.path substringFromIndex:basePath.length])];
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] fileType];
    if (fileType) {
      if ([fileType isEqualToString:NSFileTypeDirectory]) {
        if (indexFilename) {
          NSString *indexPath = [filePath stringByAppendingPathComponent:indexFilename];
          NSString *indexType = [[[NSFileManager defaultManager] attributesOfItemAtPath:indexPath error:NULL] fileType];
          if ([indexType isEqualToString:NSFileTypeRegular]) {
            return [GCDWebServerFileResponse responseWithFile:indexPath];
          }
        }
      } else if ([fileType isEqualToString:NSFileTypeRegular]) {
        if (allowRangeRequests) {
          response = [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
          [response setValue:@"bytes" forAdditionalHeader:@"Accept-Ranges"];
        } else {
          response = [GCDWebServerFileResponse responseWithFile:filePath];
        }
      }
    }
    if (response) {
      response.cacheControlMaxAge = cacheAge;
    } else {
      response = [GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound];
    }
    return response;
  }];
  
  [self.webServer addHandlerForMethod:@"GET"
                   pathRegex:@"/auth"
                requestClass:[GCDWebServerRequest class]
                processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
     if (![weakSelf isAuthorizedWithHeaders:request.headers]) {
       return [GCDWebServerDataResponse responseWithStatusCode:403];
     }

    GCDWebServerDataResponse *response = [GCDWebServerDataResponse new];
    NSString *cookieHeader = [NSString stringWithFormat:@"%@; HttpOnly", weakSelf.cookie];

    [response setValue:cookieHeader forAdditionalHeader:@"Set-Cookie"];

    return response;
  }];
  
  [self.webServer addHandlerForMethod:@"DELETE"
                  pathRegex:@"/files/*"
               requestClass:[GCDWebServerRequest class]
               processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
    if (![weakSelf isAuthorizedWithCookie:request.headers]) {
      return [GCDWebServerDataResponse responseWithStatusCode:401];
    }
    
    NSString *visitedPath = request.path;
    NSString *fileName = [visitedPath substringFromIndex:6];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *mediaPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/media/"];
    
    NSString *filePath = [mediaPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
      return [GCDWebServerDataResponse responseWithText:@"deleted"];
    } else {
      return [GCDWebServerDataResponse responseWithStatusCode:404];
    }
  }];
  
  [self.webServer addHandlerForMethod:@"POST"
                            pathRegex:@"/files"
                         requestClass:[GCDWebServerMultiPartFormRequest class]
                         processBlock:^GCDWebServerResponse *(GCDWebServerMultiPartFormRequest* request) {
    if (![weakSelf isAuthorizedWithCookie:request.headers]) {
      return [GCDWebServerDataResponse responseWithStatusCode:401];
    }
    NSString *newGuidString = [[NSUUID new] UUIDString];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *mediaPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/media/"];
    
    BOOL isDir;
    if (!([fileManager fileExistsAtPath:mediaPath isDirectory:&isDir] && isDir)) {
      [fileManager createDirectoryAtPath:mediaPath withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    GCDWebServerMultiPartFile *gcdFile =  request.files.firstObject;

    NSString *fileExtension = [weakSelf fileExtensionAssociatedWithMimeType:gcdFile.mimeType];
    if (fileExtension == NULL) {
      [SentryClient.sharedClient reportUserException:@"File Extension Not Found"
                                              reason:[gcdFile.mimeType stringByAppendingString:@" matches no extensions"] language:@"n/a" lineOfCode:@"185" stackTrace:@[] logAllThreads:false terminateProgram:false];
      fileExtension = @"";
    }
    
    NSString *fileName = [newGuidString stringByAppendingString:fileExtension];
    NSString *filePath = [mediaPath stringByAppendingPathComponent:fileName];

    NSError *error;

    [fileManager moveItemAtPath:gcdFile.temporaryPath toPath:filePath error:&error];
    
    BOOL success = error == nil;
    if (success) {
      success = [fileManager fileExistsAtPath:filePath];
      if (success) {
        NSLog(@"file saved to %@", filePath);
        return [GCDWebServerDataResponse responseWithText:[NSString stringWithFormat:@"{\"uuid\":\"%@\"}", fileName]];
      }
    }
    NSLog(@"%@", error);

    return [GCDWebServerDataResponse responseWithStatusCode:404];
  }];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.webServer startWithPort:8081 bonjourName:@"CROWDLABDIDTHIS"];
  });
}

@end
