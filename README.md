
# mm_soft_deleted

Soft Delete MongoMapper models

## Examples / How-To:

    # in your gemfile:
    gem 'mm_soft_deleted'

    # in an initializer:
    require 'mongo_mapper/soft_deleted'

    # in your model:
    class User
      include MongoMapper
      include MongoMapper::SoftDeleted
    end

    u = User.create!(first_name: 'Scott', last_name: 'Taylor')
    User.count #=> 1
    u.destroy!
    User.count #=> 0
    User.soft_deleted.count #=> 1

    soft_deleted_user = User.soft_deleted.first
    soft_deleted_user.soft_deleted? #=> true
    soft_deleted_user.soft_delete_restore!

    User.count #=> 1

## How it works:

This will store all soft deleted records into the 'soft-deleted-records' collection.

When deleting a record, the raw data will be stored as a SoftDeletedRecord, along with a few extra attributes:

* _type (the class of the object being deleted)
* _deleted_at

The convenience finder "soft_deleted" queries against the soft deleted collection, but returns a real model object, which can be used just as if it were still present.
