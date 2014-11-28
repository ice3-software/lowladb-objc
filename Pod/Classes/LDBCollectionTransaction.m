//
//  LDBCollectionTransaction.m
//  Pods
//
//  Created by Stephen Fortune on 28/11/2014.
//
//

#import "LDBCollectionTransaction.h"

@interface LDBCollectionTransaction (){
    
@private
    
    NSMutableOrderedSet *_insertedObjects;
    
}


@end

@implementation LDBCollectionTransaction

@dynamic insertedObjects;


#pragma mark - Ctor / dtor

-(instancetype) initWithCollection:(LDBCollection *)collection{

    self = [super init];
    
    if(self){
        
        _collection = collection;
        _insertedObjects = [[NSMutableOrderedSet alloc] init];
        
    }

    return self;
}

#pragma mark - Methods for registering changes to be committed

-(void) insert:(LDBObject *)object{

    @synchronized(_insertedObjects){
        [_insertedObjects addObject:object];
    }

}

#pragma mark - Accessor methods

-(NSOrderedSet *)insertedObjects{
    
    @synchronized(_insertedObjects){
        return [NSOrderedSet orderedSetWithOrderedSet:_insertedObjects];
    }

}

@end
