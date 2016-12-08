class CreateCaptureCache < ActiveRecord::Migration
  def change
    create_table :capture_caches do |t|
      t.string :packet_type
      t.string :captured_data
      t.binary :raw_data , :limit => 1.kilobytes
      t.boolean :processed
      
      t.timestamps null: false
    end
  end
end
