class AvmGroup
  include Dictionary

  def self.all_entries
    @@all_entries ||= populate( [
      { :id => 1, :name => 'Creator' },
      { :id => 2, :name => 'Content' },
      { :id => 3, :name => 'Observation' },
      { :id => 4, :name => 'Coordinate' },
      { :id => 5, :name => 'Publisher' }
    ] )
  end

  def avms
    Avm.fetch( :all ).select{ |avm| avm.avm_group_id == self.id }
  end

end

