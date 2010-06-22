class Display
  include Dictionary

  def self.all_entries
    @@all_entries ||= populate( [
      { :id => 1, :name => "visible" },
      { :id => 2, :name => "hidden" }
    ] )
  end

end

