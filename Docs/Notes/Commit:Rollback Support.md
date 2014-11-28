#Commit / Rollback Support

CoreData offers commit / rollback support for transactions. This is a few notes around how I'm going to attempt to implement it (simple first draft of the classes and models):

- `LDBCollectionTransaction`: class representing the 'transaction'. Requires a collection to be injected. Basic acts as a decorator to an `LDBCollection` that adds additional support for transactional operations via commit / rollback methods.
	
	- `NSOrderedSet *deletedObjects`: a set of objects to bedeleted
	
	- `NSOrderedSet *updatedObjects`: a set of objects to be updated
	
	- `NSOrderedSet *insertedObjects`: a set of objects to be inserted
	
	- Above properties are atomic, readonly, copy. They are also `@dynamic` and are backed by private `NSMutableOrderedSet` ivars.
	
	- They are sets because we want objects to be added to only be added once.
	
	- They have associated `insert`, `delete` and `update` methods.
	
	- Important that the integrity of these sets is maintained, i.e. check that the same object does not exist in any of the 3 sets.


###Other Notes

- 'Transaction' is used here to describe adding the basic abillity to perform multiple inserts, deletes and updates in a collection all at once on 'commit' or discard the changes and 'rollback'.

- The changes to be applied to the collection on commit are held in memory.

- Registering these changes for a transaction does not affect the database or the synchronization routine until they are committed.

- Note does `LDBObject` implement equality checking ?