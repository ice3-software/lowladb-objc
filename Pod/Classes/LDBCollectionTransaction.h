//
//  LDBCollectionTransaction.h
//  Pods
//
//  Created by Stephen Fortune on 28/11/2014.
//
//

#import <Foundation/Foundation.h>
#import "LDBCollection.h"
#import "LDBObject.h"


/**
 
 Decorator class for LDBCollection that adds support for transaction-like commit / rollbacks.
 
 @author Steve Fortune
 
 */
@interface LDBCollectionTransaction : NSObject

@property (readonly, copy) NSOrderedSet *insertedObjects;

@property (readonly, weak) LDBCollection *collection;

-(instancetype) initWithCollection:(LDBCollection *)collection;

-(void) insert:(LDBObject *)object;

@end
