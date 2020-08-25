//
//  MediaMiddleman.h
//  Engage
//
//  Created by Thomas Lee on 20/02/2020.
//

#import <Foundation/Foundation.h>
#import <GCDWebServers/GCDWebServers.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaMiddleman : NSObject

@property (strong, nonatomic) GCDWebServer *webServer;
@property (strong, nonatomic) NSString *cookie;
@property (strong, nonatomic) NSDictionary *mimeMap;
- (void) setup;
@end

NS_ASSUME_NONNULL_END
