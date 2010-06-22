class RemoveTsearch < ActiveRecord::Migration
  def self.up
    remove_column :image_sets, :vectors
    remove_column :news_categories, :vectors
    remove_column :news_items, :vectors
    remove_column :packages, :vectors
    remove_column :pages, :vectors
    remove_column :promotions, :vectors
    remove_column :resource_lists, :vectors
    remove_column :video_sets, :vectors
    remove_column :blog_authors, :vectors
    remove_column :blogs, :vectors
    remove_column :blog_categories, :vectors
    remove_column :exhibits, :vectors
    remove_column :fyles, :vectors
  end

  def self.down
  end
end
