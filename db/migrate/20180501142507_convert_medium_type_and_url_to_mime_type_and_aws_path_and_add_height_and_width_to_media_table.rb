class ConvertMediumTypeAndUrlToMimeTypeAndAwsPathAndAddHeightAndWidthToMediaTable < ActiveRecord::Migration[5.1]
  def change
    rename_column :media, :medium_type, :mime_type
    rename_column :media, :url,         :aws_path

    change_column_default(:media, :mime_type, nil)

    add_column :media, :height, :integer, null: false
    add_column :media, :width,  :integer, null: false
  end
end
