class AddIndexToStoreIdentifierString < ActiveRecord::Migration
  def change
    add_index :stores, :identifier_string
  end
end
