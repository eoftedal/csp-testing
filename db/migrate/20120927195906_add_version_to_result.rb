class AddVersionToResult < ActiveRecord::Migration
  def change
    add_column :results, :version, :double

  end
end
