//
//  LDBCollectionTransaction.h
//  Pods
//
//  Created by Stephen Fortune on 28/11/2014.
//
//

#import <Foundation/Foundation.h>
#import "LDBCollection.h"

@interface LDBCollectionTransaction : NSObject

@property (readonly, weak) LDBCollection *collection;

-(id) initWithCollection:(LDBCollection *)collection;

@end
