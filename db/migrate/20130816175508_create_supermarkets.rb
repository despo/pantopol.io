class CreateSupermarkets < ActiveRecord::Migration
  def change
    create_table :supermarkets do |t|
      t.references :city, index: true
      t.string :name
      t.string :address
      t.string :identifier_string

      t.timestamps
    end
  end
end
