class ImageSet < ActiveRecord::Base
  # Subject.Name, Credit, Facility, Instrument
  AVM_SEARCHABLE_DATA = [16, 20, 25, 26]

  include Revisionality
  include Visibility
  include PrettyUrlity

  scope :image_gallery_curated, :conditions => { :image_gallery => true }
  scope :virtual_museum_curated, :conditions => { :virtual_museum => true }
  scope :by_date, :order => 'image_created DESC'

  has_one  :image, :as => :attachable, :dependent => :destroy
  has_many :secondary_images, :as => :attachable, :dependent => :destroy
  has_one  :square_graphic, :as => :attachable, :dependent => :destroy
  has_one  :high_definition_graphic, :as => :attachable, :dependent => :destroy
  has_one  :fullscreen_graphic, :as => :attachable, :dependent => :destroy
  has_one  :zoomable, :as => :attachable, :dependent => :destroy
  has_one  :statistic, :as => :statisticable, :dependent => :destroy
  
  has_many   :package_items, :as => :packaging
  has_many   :packages, :through => :package_items
  
  has_many   :resource_list_items, :as => :resource_listing, :dependent => :destroy
  has_many   :resource_lists, :through => :resource_list_items

  has_many   :exhibit_items, :as => :exhibiting, :dependent => :destroy
  has_many   :exhibits, :through => :exhibit_items

  attr_accessor :sub_category

#  def before_save
#    ImageSet.find(:all, :include => :image).each do |image_set|
#      self.avm_searchable_data = AvmTag.find(:all, :conditions => ["image_id=? AND avm_id IN (?)", image_set.image.id, ImageSet::AVM_SEARCHABLE_DATA]).collect(&:value).join(' ')
#    end
#  end
  def before_publish
    avm_data_string = ""
    if (!image.nil? && (avm_data = image.avm_data))
      avm_data_string = "#{avm_data['subject_name'].join(' ')} #{avm_data['credit']} #{avm_data['facility'].join(' ')} #{avm_data['instrument'].join(' ')}"
    end
    self.avm_searchable_data = "#{self.abstract} #{avm_data_string}" 
  end

  # Because this isn't triggered by the revisionable behavior.
  def after_destroy
    ExhibitItem.destroy_all( [ "exhibiting_id=? AND exhibiting_type=?", self.id, self.class.name ] )
    ResourceListItem.destroy_all( [ "resource_listing_id=? AND resource_listing_type=?", self.id, self.class.name ] )
    PackageItem.destroy_all( [ "packaging_id=? AND packaging_type=?", self.id, self.class.name ] )
  end

  def after_publish
    self.resource_list_items.each{|a| a.class.find_or_create(a.attributes.merge('resource_listing_id' => self.published_resource.id, 'position' => nil ))}
    self.exhibit_items.each{|a| a.class.find_or_create(a.attributes.merge('exhibiting_id' => self.published_resource.id, 'position' => nil ))}
    self.package_items.each{|a| a.class.find_or_create(a.attributes.merge('packaging_id' => self.published_resource.id, 'position' => nil ))}
  end


  def self.revision_clonables
    [ :image, :fullscreen_graphic, :high_definition_graphic, :square_graphic, :zoomable, :secondary_images ]
  end
  
  def self.name_field
    :title
  end
  
  def prepopulate_from_avm
    if ( !image.nil? && ( avm_data = image.avm_data ) )
      self.sscid = avm_data['id'] if ( self.sscid.nil? || self.sscid.empty? )
      self.image_created ||= Date.parse( avm_data['date'] ) if ( avm_data['date']  )
      self.title = avm_data['title'] if ( self.title.nil? || self.title.empty? )
      self.abstract = avm_data['headline'] if ( self.abstract.nil? || self.abstract.empty? )
      self.body = ( avm_data['description'] || "" ).split( /\n\n/ ).collect{ |p| "<p>" + p + "</p>" }.join( "" ) if ( self.body.nil? || self.body.empty? )
      self.photo_credit = avm_data['credit'] if ( self.photo_credit.nil? || self.photo_credit.empty? )
      self.avm_type = avm_data['type']
      self.avm_spatial_quality = avm_data['spatial_quality']

      self.save
    end
  end
  
  def propagate_avm_data!( url_prefix = "" )
    avm_data = self.image.avm_data.dup
    self.secondary_images.each do |secondary_image|
      if File.exists?( dependent_file = secondary_image.full_filename )
        avm_data['resourceid'] = secondary_image.filename
        avm_data['resourceurl'] = "#{url_prefix}#{secondary_image.public_filename}"
        Avm.clear_xmp( dependent_file )
        Avm.write_xmp( dependent_file, avm_data )
      end
    end
  end
  
  def has_zoomable?
    !self.zoomable.nil? && !self.zoomable.filename.nil? && Dir[ File.join( RAILS_ROOT, 'public', File.dirname( self.zoomable.public_filename ), "**", "ImageProperties.xml" ) ].first
  end
end
