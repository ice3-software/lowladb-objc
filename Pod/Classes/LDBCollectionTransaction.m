//
//  LDBCollectionTransaction.m
//  Pods
//
//  Created by Stephen Fortune on 28/11/2014.
//
//

#import "LDBCollectionTransaction.h"

@interface LDBCollectionTransaction (){
    
}

@end

@implementation LDBCollectionTransaction

#pragma mark - Ctor / dtor

-(instancetype) initWithCollection:(LDBCollection *)collection{

    self = [super init];
    
    if(self){
        
        _collection = collection;
        _insertedObjects = [[NSMutableOrderedSet alloc] init];
        _updatedObjects = [[NSMutableOrderedSet alloc] init];
        _removedObjects = [[NSMutableOrderedSet alloc] init];
        
    }

    return self;
}

#pragma mark - Transactional methods

-(void) insert:(LDBObject *)object{

    @synchronized(_insertedObjects){
        [_insertedObjects addObject:object];
    }

}

-(void) update:(LDBObject *)object{
    
    @synchronized(_updatedObjects){
        [_updatedObjects addObject:object];
    }
    
}

-(void) remove:(LDBObject *)object{
    
    @synchronized(self){
        
        if([_insertedObjects containsObject:object]){
            [_insertedObjects removeObject:object];
        }
        else{
            [_removedObjects addObject:object];
        }
        
    }
    
}

#pragma mark - Accessor methods

/// ...

@end
