class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :store, index: true
      t.name
      t.float :price, :precision => 5, :scale => 2, :default => 0, :null => false
      t.date :date
      t.string :unit

      t.timestamps
    end
  end
end
