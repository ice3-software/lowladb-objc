//
//  LDBClient.h
//  lowladb-objc
//
//  Created by mark on 7/3/14.
//
//

#import <Foundation/Foundation.h>
@class LDBDb;
@class LDBClient;

@interface LDBClient : NSObject

@property (readonly) NSString *version;

- (void)dropDatabase:(NSString *)dbName;
- (LDBDb *)getDatabase:(NSString *)dbName;
- (NSArray *)getDatabaseNames;

@end
