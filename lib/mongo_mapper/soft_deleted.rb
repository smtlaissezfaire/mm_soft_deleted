require 'mongo_mapper'

class SoftDeletedRecord
  include MongoMapper::Document

  key :_type, String
  key :_original_type, String
  key :_deleted_at, Time
end

module MongoMapper::SoftDeleted
  class << self
    def enabled?
      instance_variable_defined?(:@enabled) ? @enabled : true
    end

    attr_writer :enabled
  end

  def self.included(mod)
    mod.extend(MongoMapper::SoftDeleted::ClassMethods)
    mod.send(:include, MongoMapper::SoftDeleted::InstanceMethods)

    mod.after_destroy do
      soft_delete_destroy(self) if MongoMapper::SoftDeleted.enabled?
    end
  end

  module InstanceMethods
    def soft_delete_destroy(obj)
      db = MongoMapper.database

      row = obj.attributes.dup
      row[:_type] = obj.class.name
      row[:_deleted_at] = Time.now
      row[:_original_type] = obj.attributes[:_type]

      db['soft_deleted_records'].insert(row)
    end

    def soft_delete_restore!
      db = MongoMapper.database
      source_class = _type.constantize
      collection_name = source_class.collection_name

      attrs_for_insertion = attributes.except(:_type, :_deleted_at, :_original_type)
      if !attributes[:_original_type].blank?
        attrs_for_insertion[:_type] = attributes[:_original_type]
      end

      db[collection_name].insert(attrs_for_insertion)
      db['soft_deleted_records'].remove({
        _id: id
      })

      source_class.find(id).on_soft_delete_restore
    end

    def soft_deleted?
      respond_to?(:_deleted_at) && _deleted_at ? true : false
    end

    # override this on classes
    def on_soft_delete_restore
    end
  end

  module ClassMethods
    def soft_deleted
      soft_deleted_classes = [self, descendants].flatten
      soft_deleted_class_names = soft_deleted_classes.map(&:name)

      SoftDeletedRecord.where({
        _type: {
          '$in': soft_deleted_class_names
        }
      })
    end
  end
end
