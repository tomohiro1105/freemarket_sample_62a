class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.integer    :post_code,    null: false
      t.string     :prefecuture,   null: false
      t.string     :address,       null: false
      t.string     :building,      null: false
      t.references  :user,         foreign_key: true
      t.timestamps
    end
  end
end
