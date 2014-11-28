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
 
 This class uses `NSMutableOrderedSet`s to register changes to be commited in the transaction 
 because:
 
 - We want to be able to append objects on to the sets (mutable)
 - We want to order of the changes to be applied in the order that they were registered (ordered)
 - We don't want duplicate objects registered (set)

 Because most foundation's mutable collection classes are not thread safe (and this may be used 
 across multiple threads), public methods that mutate these sets (`insert`, `update`, `remove`, 
 `commit` and `rollback`) implement mutex locks to avoid race conditions.
 
 @author Steve Fortune
 
 */
@interface LDBCollectionTransaction : NSObject

@property (readonly, copy) NSMutableOrderedSet *insertedObjects;

@property (readonly, copy) NSMutableOrderedSet *updatedObjects;

@property (readonly, copy) NSMutableOrderedSet *removedObjects;

@property (readonly, weak) LDBCollection *collection;

-(instancetype) initWithCollection:(LDBCollection *)collection;

-(void) insert:(LDBObject *)object;

-(void) update:(LDBObject *)object;

-(void) remove:(LDBObject *)object;

-(void) commit;

-(void) rollback;

@end
