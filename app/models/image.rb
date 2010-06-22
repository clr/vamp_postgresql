class Image < Attachment
  belongs_to :attachable, :polymorphic => true
  has_attachment :processor => 'Rmagick',
                 :content_type => Technoweenie::AttachmentFu.content_types,
                 :storage => :file_system,
                 :max_size => 4.gigabytes,
                 :path_prefix => 'public/uploaded_files/images',
                 :keep_profile => true
  validates_as_attachment
  has_many :avm_tags

  def clone
    new_attachment = super
    new_attachment.avm_tags = self.avm_tags.collect( &:clone )
    return new_attachment
  end

  def avm_data
    @data = {}
    Avm.all.each do |avm|
      case avm.data_type
      when :text, :alternatives, :iptc_contact
        tag_match = avm_tags.detect{ |avm_tag| avm_tag.avm_id == avm.id }
        @data[ avm.name ] = tag_match ? tag_match.value : nil
      when :sequence, :bag
        @data[ avm.name ] = avm_tags.select{ |avm_tag| avm_tag.avm_id == avm.id }.sort{ |a, b| ( a.position || 10 ) <=> ( b.position || 10 ) }.collect( &:value )
      end
    end
    @data
  end

  def avm_data=( data )
    transaction do
      # Clear all data.
      avm_tags.clear
      Avm.all.each do |avm|
        case avm.data_type
        when :text, :alternatives, :iptc_contact
          avm_tags.create( :value => data[ avm.name ], :avm_id => avm.id )
        when :sequence, :bag
          data[ avm.name ].each_with_index do |value, i|
            avm_tags.create( :value => value, :avm_id => avm.id, :position => i )
          end if data[ avm.name ]
        end
      end
    end
  end
  
  def sync_avm_from_file
    self.avm_data = Avm.read_xmp( self.full_filename )
  end

  def sync_avm_to_file
    Avm.clear_xmp( self.full_filename )
    Avm.write_xmp( self.full_filename, avm_data )
  end

end

