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

    @synchronized(self){
        
        if([_updatedObjects containsObject:object]){
            [_updatedObjects removeObject:object];
        }
        [_insertedObjects addObject:object];
    }

}

-(void) update:(LDBObject *)object{
    
    @synchronized(self){
        
        if(![_insertedObjects containsObject:object]){
            [_updatedObjects addObject:object];
        }
    }
    
}

-(void) remove:(LDBObject *)object{
    
    @synchronized(self){
        
        if([_insertedObjects containsObject:object]){
            [_insertedObjects removeObject:object];
        }
        else if([_updatedObjects containsObject:object]){
            [_updatedObjects removeObject:object];
        }
        else{
            [_removedObjects addObject:object];
        }
        
    }
    
}

-(void) commit{

    @synchronized(self){
    
        for(LDBObject *insertObject in _insertedObjects){
            [self.collection insert:insertObject];
        }
        for(LDBObject *updateObject in _updatedObjects){
            [self.collection save:updateObject];
        }
        for(LDBObject *removeObject in _removedObjects){
            /// @todo...
        }
        
        [_insertedObjects removeAllObjects];
        [_updatedObjects removeAllObjects];
        [_removedObjects removeAllObjects];
    }
}

-(void) rollback{

    @synchronized(self){

        [_insertedObjects removeAllObjects];
        [_updatedObjects removeAllObjects];
        [_removedObjects removeAllObjects];

    }
}

#pragma mark - Accessor methods

/// ...

@end
