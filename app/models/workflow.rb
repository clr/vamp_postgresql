class Workflow
  include Dictionary

  def self.all_entries
    @@all_entries ||= populate( [
      { :id => 1, :name => "published" },
      { :id => 2, :name => "pending" },
      { :id => 3, :name => "expired" },
      { :id => 4, :name => "deleted" }
    ] )
  end

end

