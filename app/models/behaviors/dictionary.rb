# See the README for details.
module Dictionary

  # Bootstrap the class and instance methods.
  def self.included( klass )
    klass.extend ClassMethods

    attr_accessor :id
    attr_accessor :name
  end
  
  #
  # Class Methods.
  #
  module ClassMethods

    def populate( entries )
      entries.collect do |entry| 
        self.new( entry )
      end
    end
    
    def all
      all_entries
    end
    
    def fetch( what )
      case( what.class.name )
      when "NilClass"
        raise "#{self.to_s} error: Cannot fetch #{self.to_s.downcase} looking for a Nil object."
      when "Symbol"
        case( what )
        when :all
          all_entries
        when :first
          all_entries[0]
        else
          raise "#{self.to_s} error: Fetch symbol misunderstood."
        end
      when "Fixnum"
        all_entries.detect{ |e| e.id == what }
      when "String"
        all_entries.detect{ |e| ( e.name == what ) || ( e.name.gsub( " ", "_" ).downcase == what.gsub( " ", "_" ).downcase ) }
      else
        raise "#{self.to_s} error: What type of #{self.to_s.downcase} is that?"
      end

    end

    # select_tag() helper
    def options
      self.fetch( :all ).collect{ |e| [ e.name, e.id ] }
    end

    # We want to quickly (painlessly) fetch a record via .#{name} as
    # long as there's no method collision.
    def method_missing( name, *args)
      if species = name.to_s.match( /\w+/ ) and record = self.fetch( species[0] )
        record
      else
        super
      end
    end
    
  end

  #
  # Instance Methods.
  #
  def initialize( attributes )
    attributes.each do |key, value|
      if self.respond_to?( key )
        self.send( ( key.to_s + "=" ).to_sym, value )
      end
    end
  end
  
  def ==( comparison )
    self.id == comparison.id
  end

  def to_i
    self.id.to_i
  end
  
  # We want to quickly (painlessly) ask .is_#{name}?
  def method_missing( name, *args)
    if species = name.to_s.match( /^is_(\w+)?/ )
      self.name.gsub( " ", "_" ).downcase == species[1]
    else
      super
    end
  end

end
  
