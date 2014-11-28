//
//  Tests.m
//  lowladb-objcTests
//
//  Created by Mark Dixon on 07/03/2014.
//  Copyright (c) 2014 Mark Dixon. All rights reserved.
//

#import "LDBClient.h"
#import "lowladb-objc/LDBCollection.h"
#import "lowladb-objc/LDBCursor.h"
#import "lowladb-objc/LDBDb.h"
#import "lowladb-objc/LDBObject.h"
#import "lowladb-objc/LDBObjectBuilder.h"
#import "lowladb-objc/LDBObjectId.h"
#import "lowladb-objc/LDBWriteResult.h"
#import "lowladb-objc/LDBCollectionTransaction.h"

@interface LDB_BasicFunctionalityTests : XCTestCase
@end

@implementation LDB_BasicFunctionalityTests

-(void)testItHasTheCorrectVersion
{
    LDBClient *client = [[LDBClient alloc] init];
    XCTAssertEqualObjects(client.version, @"0.0.1 (liblowladb 0.0.2)");
}

-(void)testItCanCreateDatabaseReferences
{
    LDBClient *client = [[LDBClient alloc] init];
    LDBDb *db = [client getDatabase:@"mydb"];
    XCTAssertEqualObjects(db.name, @"mydb");
}

-(void)testItCanCreateCollectionReferences
{
    LDBClient *client = [[LDBClient alloc] init];
    LDBDb *db = [client getDatabase:@"mydb"];
    LDBCollection *coll = [db getCollection:@"mycoll.dotted"];
    XCTAssertEqualObjects(coll.db, db);
    XCTAssertEqualObjects(coll.name, @"mycoll.dotted");
}

@end

@interface LDB_ObjectBuildingTests : XCTestCase

@end

@implementation LDB_ObjectBuildingTests

-(void)testItCanBuildDoubles
{
    LDBObject *obj = [[[LDBObjectBuilder builder] appendDouble:3.14 forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqual([obj doubleForField:@"myfield"], 3.14);
}

-(void)testItCanBuildStrings
{
    LDBObject *obj = [[[LDBObjectBuilder builder] appendString:@"mystring" forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqualObjects([obj stringForField:@"myfield"], @"mystring");
}

-(void)testItCanBuildObjects
{
    LDBObject *subObj = [[[LDBObjectBuilder builder] appendString:@"mystring" forField:@"myfield"] finish];
    LDBObject *obj = [[[LDBObjectBuilder builder] appendObject:subObj forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqualObjects([obj objectForField:@"myfield"], subObj);
}

-(void)testItCanBuildObjectIds
{
    LDBObjectId *oid = [LDBObjectId generate];
    LDBObject *obj = [[[LDBObjectBuilder builder] appendObjectId:oid forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqualObjects([obj objectIdForField:@"myfield"], oid);
}

-(void)testItCanBuildBools
{
    LDBObject *obj = [[[LDBObjectBuilder builder] appendBool:YES forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqual([obj boolForField:@"myfield"], YES);
}

-(void)testItCanBuildDates
{
    NSDate *date = [NSDate date];
    LDBObject *obj = [[[LDBObjectBuilder builder] appendDate:date forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    NSTimeInterval i1 = [date timeIntervalSince1970];
    NSTimeInterval i2 = [[obj dateForField:@"myfield"] timeIntervalSince1970];
    XCTAssertEqualWithAccuracy(i1, i2, 1e-3);
}

-(void)testItCanBuildInts
{
    LDBObject *obj = [[[LDBObjectBuilder builder] appendInt:314 forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqual([obj intForField:@"myfield"], 314);
}

-(void)testItCanBuildLongs
{
    LDBObject *obj = [[[LDBObjectBuilder builder] appendLong:314000000000000 forField:@"myfield"] finish];
    XCTAssert([obj containsField:@"myfield"]);
    XCTAssertEqual([obj longForField:@"myfield"], 314000000000000);
}

@end

@interface LDB_BasicInsertAndRetrievalTests : XCTestCase
{
    LDBClient *client;
    LDBDb *db;
    LDBCollection *coll;
}

@end

@implementation LDB_BasicInsertAndRetrievalTests

-(void)setUp
{
    client = [[LDBClient alloc] init];
    [client dropDatabase:@"mydb"];
    db = [client getDatabase:@"mydb"];
    coll = [db getCollection:@"mycoll"];
}

-(void)tearDown
{
    coll = nil;
    db = nil;
    [client dropDatabase:@"mydb"];
    client = nil;
}

-(void)testItCanCreateSingleStringDocuments
{
    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"mystring" forField:@"myfield"] finish];
    LDBWriteResult *wr = [coll insert:object];
    XCTAssertNotNil(wr.upsertedId);
}

-(void)testItCreatesANewIdForEachDocument
{
    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"mystring" forField:@"myfield"] finish];
    LDBWriteResult *wr = [coll insert:object];
    LDBWriteResult *wr2 = [coll insert:object];
    XCTAssertNotEqualObjects(wr.upsertedId, wr2.upsertedId);
}

-(void)testItCanFindTheFirstDocument
{
    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"mystring" forField:@"myfield"] finish];
    LDBWriteResult *wr = [coll insert:object];
    LDBObject *found = [coll findOne];
    NSString *check = [found stringForField:@"myfield"];
    LDBObjectId *checkId = [found objectIdForField:@"_id"];
    XCTAssertEqualObjects(check, @"mystring");
    XCTAssertEqualObjects(checkId, wr.upsertedId);
}

-(void)testItCanFindTwoDocuments
{
    LDBObject *object1 = [[[LDBObjectBuilder builder] appendString:@"mystring1" forField:@"myfield"] finish];
    LDBWriteResult *wr1 = [coll insert:object1];
    LDBObject *object2 = [[[LDBObjectBuilder builder] appendString:@"mystring2" forField:@"myfield"] finish];
    LDBWriteResult *wr2 = [coll insert:object2];
    LDBCursor *cursor = [coll find];
    XCTAssertTrue([cursor hasNext]);
    LDBObject *check1 = [cursor next];
    XCTAssertTrue([cursor hasNext]);
    LDBObject *check2 = [cursor next];
    XCTAssertFalse([cursor hasNext]);
    XCTAssertEqualObjects([wr1 upsertedId], [check1 objectIdForField:@"_id"]);
    XCTAssertEqualObjects([wr2 upsertedId], [check2 objectIdForField:@"_id"]);
}

@end


/**
 
 Mock collection class. Stubs out the methods used by LDBCollectionTransaction so
 that we can spy on the interactions without hitting the db.
 
 @note Opted to use mocks instead of checking the results written to the db because I 
 can't find a way to mutate a LDBObject instance at the moment. This means I can't reliably
 test whether an object in the db has been updated with a `save` call.
 
 @note Seems as though we can't delete objects in a collection. Not sure how to go about
 this...
 
 @author Steve Fortune
 
 */

@interface LDB_MockCollection : LDBCollection

@property (nonatomic) BOOL hasSaveBeenCalled;

@property (nonatomic) BOOL hasInsertBeenCalled;

@property (nonatomic) BOOL hasDeleteBeenCalled;

@end

@implementation LDB_MockCollection

-(id) save:(LDBObject *)object{
    _hasSaveBeenCalled = YES;
    return self;
}

-(id) insert:(LDBObject *)object{
    _hasInsertBeenCalled = YES;
    return self;
}

@end


/**
 
 Tests for basic commit / rollback support.
 
 @author Steve Fortune
 
 */

@interface LDB_TransactionTests : XCTestCase{

    LDB_MockCollection *coll;
    LDBCollectionTransaction *transaction;
    
}

@end

@implementation LDB_TransactionTests


#pragma mark - Setup / Teardown dependencies


-(void) setUp{

    coll = [[LDB_MockCollection alloc] init];
    transaction = [[LDBCollectionTransaction alloc] initWithCollection:coll];

}

-(void) tearDown{
    
    coll = nil;
    coll = nil;

}


#pragma mark - Transaction tests


-(void) testRegistersInsertedObjectWithTransaction{

    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"test" forField:@"test"] finish];
    
    [transaction insert:object];
    XCTAssertTrue([transaction.insertedObjects containsObject:object], @"Inserted object not registered with transaction");
    
}

-(void) testRegistersUpdatedObjectWithTransaction{
    
    LDBObject *initialObject = [[[LDBObjectBuilder builder] appendString:@"update-me" forField:@"update-me"] finish];
    [coll insert:initialObject];
    
    [transaction update:initialObject];
    XCTAssertTrue([transaction.updatedObjects containsObject:initialObject], @"Updated object not registered with transaction");
    
}

-(void) testRegistersRemovedObjectWithTransaction{
    
    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"deleted-me" forField:@"deleted-me"] finish];
    [coll insert:object];
    
    [transaction remove:object];
    XCTAssertTrue([transaction.removedObjects containsObject:object], @"Deleted object not registered with transaction");
    
}

-(void) testDeletingAfterInsertingResultsInNoRegistration{

    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"test" forField:@"test"] finish];

    [transaction insert:object];
    [transaction remove:object];
    
    XCTAssertFalse([transaction.insertedObjects containsObject:object], @"Deleted object remains in inserted set after being removed");
    XCTAssertFalse([transaction.removedObjects containsObject:object], @"Deleted object remains in deleted set after being removed");

}

-(void) testDeletingAfterUpdatingResultsInNoRegistration{

    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"test" forField:@"test"] finish];
    
    [transaction update:object];
    [transaction remove:object];
    
    XCTAssertFalse([transaction.updatedObjects containsObject:object], @"Deleted object remains in updated set after being removed");
    XCTAssertFalse([transaction.removedObjects containsObject:object], @"Deleted object remains in deleted set after being removed");

}

-(void) testUpdatingAfterInsertingResultsInInsert{

    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"test" forField:@"test"] finish];
    
    [transaction insert:object];
    [transaction update:object];
    
    XCTAssertFalse([transaction.updatedObjects containsObject:object], @"New updated object remains in updated set");
    XCTAssertTrue([transaction.insertedObjects containsObject:object], @"Inserted object does not remain in inserted set");

}

-(void) testSilentlyCleansUpdatedSetIfInsertAfterUpdate{

    LDBObject *object = [[[LDBObjectBuilder builder] appendString:@"test" forField:@"test"] finish];
    
    [transaction update:object];
    [transaction insert:object];
    
    XCTAssertFalse([transaction.updatedObjects containsObject:object], @"Newly inserted object remains in updated set");
    XCTAssertTrue([transaction.insertedObjects containsObject:object], @"Inserted object not added to inserted set");

}

-(void) testCommitsAllToLowlaCollection{

    LDBObject *insertedObject = [[[LDBObjectBuilder builder] appendString:@"already" forField:@"here"] finish];
    LDBObject *removeableObject = [[[LDBObjectBuilder builder] appendString:@"delete" forField:@"me"] finish];

    [coll insert:insertedObject];
    [coll insert:removeableObject];
    
    [transaction remove:removeableObject];
    [transaction update:insertedObject];
    [transaction insert:[[[LDBObjectBuilder builder] appendString:@"all-new" forField:@"and-shiney"] finish]];
    
    [transaction commit];
    
    XCTAssertTrue(coll.hasInsertBeenCalled, @"Item not inserted");
    XCTAssertTrue(coll.hasSaveBeenCalled, @"Item not updated");
    XCTAssertTrue(coll.hasDeleteBeenCalled, @"Item not deleted - note, not current sure how to delete items in a collection");
 
    XCTAssertEqual([transaction.insertedObjects count], 0, @"Set of inserted objects not cleared after commit");
    XCTAssertEqual([transaction.updatedObjects count], 0, @"Set of updated objects not cleared after commit");
    XCTAssertEqual([transaction.removedObjects count], 0, @"Set of removed objects not cleared after commit");
}

@end
