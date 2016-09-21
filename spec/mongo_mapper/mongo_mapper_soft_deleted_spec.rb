require "spec_helper"

class MongoMapperSoftDeleteFixtureModel
  include MongoMapper::Document
  include MongoMapper::SoftDeleted

  key :test_string, String
  key :test_int, Integer
  timestamps!
end

class MongoMapperSoftDeleteDescendantFixtureModel < MongoMapperSoftDeleteFixtureModel
end

describe MongoMapper::SoftDeleted do
  it "should be able to destroy the record" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.save!
    obj.destroy

    MongoMapperSoftDeleteFixtureModel.where(_id: obj.id).count.should eq(0)
  end

  it "should store the record in the soft_deleted_records table" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.save!
    obj.destroy

    SoftDeletedRecord.where(_id: obj.id).count.should eq(1)
  end

  it "should be able to find it through the soft_deleted method" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.save!
    obj.destroy

    MongoMapperSoftDeleteFixtureModel.soft_deleted.where(_id: obj.id).count.should eq(1)
  end

  it "should return with the original class" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.save!
    obj.destroy

    MongoMapperSoftDeleteFixtureModel.soft_deleted.first.class.should eq(MongoMapperSoftDeleteFixtureModel)
  end

  it "should have all the properties" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.test_string = "Foo Bar!"
    obj.test_int = 10
    obj.save!
    obj.destroy

    soft_deleted_obj = MongoMapperSoftDeleteFixtureModel.soft_deleted.first
    soft_deleted_obj.test_string.should eq("Foo Bar!")
    soft_deleted_obj.test_int.should eq(10)
  end

  it "should be able to restore a record" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.test_string = "Foo Bar!"
    obj.test_int = 10
    obj.save!
    obj.destroy

    soft_deleted_obj = MongoMapperSoftDeleteFixtureModel.soft_deleted.first
    soft_deleted_obj.soft_delete_restore!

    restored_obj = MongoMapperSoftDeleteFixtureModel.first
    restored_obj.id.should eq(obj.id)
    restored_obj.test_string.should eq("Foo Bar!")
    restored_obj.test_int.should eq(10)
    # restored_obj.attributes.should_not include(:)
  end

  it "should remove a restored record from the deleted table" do
    obj = MongoMapperSoftDeleteFixtureModel.new
    obj.test_string = "Foo Bar!"
    obj.test_int = 10
    obj.save!
    obj.destroy

    soft_deleted_obj = MongoMapperSoftDeleteFixtureModel.soft_deleted.first
    soft_deleted_obj.soft_delete_restore!

    SoftDeletedRecord.count.should eq(0)
  end

  it "should be able to restore a subclassed obj" do
    obj = MongoMapperSoftDeleteDescendantFixtureModel.new
    obj.test_string = "Foo Bar!"
    obj.test_int = 10
    obj.save!
    obj.destroy

    soft_deleted_obj = MongoMapperSoftDeleteDescendantFixtureModel.soft_deleted.first
    soft_deleted_obj.soft_delete_restore!

    MongoMapperSoftDeleteDescendantFixtureModel.count.should eq(1)
  end

  it "should be able to find subclasses from a parent class" do
    obj1 = MongoMapperSoftDeleteFixtureModel.new
    obj1.save!
    obj1.destroy

    obj2 = MongoMapperSoftDeleteDescendantFixtureModel.new
    obj2.save!
    obj2.destroy

    MongoMapperSoftDeleteFixtureModel.soft_deleted.count.should == 2
  end
end
