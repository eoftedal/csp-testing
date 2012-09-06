class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :useragent
      t.text :results
      t.integer :total
      t.integer :success

      t.timestamps
    end
  end
end
