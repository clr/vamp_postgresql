class Avm
  include Dictionary
  attr_accessor :tag_name, :schema, :data_type, :avm_group_id
  require 'open3'
  require 'rexml/document'

  def self.all_entries
    @@all_entries ||= populate( [
      { :id => 1, :tag_name => 'Creator', :schema => 'photoshop:Source', :data_type => :text, :avm_group_id => 1 },
      { :id => 2, :tag_name => 'CreatorURL', :schema => 'Iptc4xmpCore:CiUrlWork', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 3, :tag_name => 'Contact.Name', :schema => 'dc:creator', :data_type => :sequence, :avm_group_id => 1 },
      { :id => 4, :tag_name => 'Contact.Email', :schema => 'Iptc4xmpCore:CiEmailWork', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 5, :tag_name => 'Contact.Telephone', :schema => 'Iptc4xmpCore:CiTelWork', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 6, :tag_name => 'Contact.Address', :schema => 'Iptc4xmpCore:CiAdrExtadr', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 7, :tag_name => 'Contact.City', :schema => 'Iptc4xmpCore:CiAdrCity', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 8, :tag_name => 'Contact.StateProvince', :schema => 'Iptc4xmpCore:CiAdrRegion', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 9, :tag_name => 'Contact.PostalCode', :schema => 'Iptc4xmpCore:CiAdrPcode', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 10, :tag_name => 'Contact.Country', :schema => 'Iptc4xmpCore:CiAdrCtry', :data_type => :iptc_contact, :avm_group_id => 1 },
      { :id => 11, :tag_name => 'Rights', :schema => 'xapRights:UsageTerms', :data_type => :alternatives, :avm_group_id => 1, :input_type => :textarea },
      { :id => 12, :tag_name => 'Title', :schema => 'dc:title', :data_type => :alternatives, :avm_group_id => 2 },
      { :id => 13, :tag_name => 'Headline', :schema => 'photoshop:Headline', :data_type => :text, :avm_group_id => 2 },
      { :id => 14, :tag_name => 'Description', :schema => 'dc:description', :data_type => :alternatives, :avm_group_id => 2 },
      { :id => 15, :tag_name => 'Subject.Category', :schema => 'avm:Subject.Category', :data_type => :bag, :avm_group_id => 2 },
      { :id => 16, :tag_name => 'Subject.Name', :schema => 'dc:subject', :data_type => :bag, :avm_group_id => 2 },
      { :id => 17, :tag_name => 'Distance', :schema => 'avm:Distance', :data_type => :sequence, :avm_group_id => 2 },
      { :id => 18, :tag_name => 'Distance.Notes', :schema => 'avm:Distance.Notes', :data_type => :text, :avm_group_id => 2 },
      { :id => 19, :tag_name => 'ReferenceURL', :schema => 'avm:ReferenceURL', :data_type => :text, :avm_group_id => 2 },
      { :id => 20, :tag_name => 'Credit', :schema => 'photoshop:Credit', :data_type => :text, :avm_group_id => 2 },
      { :id => 21, :tag_name => 'Date', :schema => 'photoshop:DateCreated', :data_type => :text, :avm_group_id => 2 },
      { :id => 22, :tag_name => 'ID', :schema => 'avm:ID', :data_type => :text, :avm_group_id => 2 },
      { :id => 23, :tag_name => 'Type', :schema => 'avm:Type', :data_type => :text, :avm_group_id => 2 },
      { :id => 24, :tag_name => 'Image.ProductQuality', :schema => 'avm:Image.ProductQuality', :data_type => :text, :avm_group_id => 2 },
      { :id => 25, :tag_name => 'Facility', :schema => 'avm:Facility', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 26, :tag_name => 'Instrument', :schema => 'avm:Instrument', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 27, :tag_name => 'Spectral.ColorAssignment', :schema => 'avm:Spectral.ColorAssignment', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 28, :tag_name => 'Spectral.Band', :schema => 'avm:Spectral.Band', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 29, :tag_name => 'Spectral.Bandpass', :schema => 'avm:Spectral.Bandpass', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 30, :tag_name => 'Spectral.CentralWavelength', :schema => 'avm:Spectral.CentralWavelength', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 31, :tag_name => 'Spectral.Notes', :schema => 'avm:Spectral.Notes', :data_type => :alternatives, :avm_group_id => 3 },
      { :id => 32, :tag_name => 'Temporal.StartTime', :schema => 'avm:Temporal.StartTime', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 33, :tag_name => 'Temporal.IntegrationTime', :schema => 'avm:Temporal.IntegrationTime', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 34, :tag_name => 'DatasetID', :schema => 'avm:DatasetID', :data_type => :sequence, :avm_group_id => 3 },
      { :id => 35, :tag_name => 'Spatial.CoordinateFrame', :schema => 'avm:Spatial.CoordinateFrame', :data_type => :text, :avm_group_id => 4 },
      { :id => 36, :tag_name => 'Spatial.Equinox', :schema => 'avm:Spatial.Equinox', :data_type => :text, :avm_group_id => 4 },
      { :id => 37, :tag_name => 'Spatial.ReferenceValue', :schema => 'avm:Spatial.ReferenceValue', :data_type => :sequence, :avm_group_id => 4 },
      { :id => 38, :tag_name => 'Spatial.ReferenceDimension', :schema => 'avm:Spatial.ReferenceDimension', :data_type => :sequence, :avm_group_id => 4 },
      { :id => 39, :tag_name => 'Spatial.ReferencePixel', :schema => 'avm:Spatial.ReferencePixel', :data_type => :sequence, :avm_group_id => 4 },
      { :id => 40, :tag_name => 'Spatial.Scale', :schema => 'avm:Spatial.Scale', :data_type => :sequence, :avm_group_id => 4 },
      { :id => 41, :tag_name => 'Spatial.Rotation', :schema => 'avm:Spatial.Rotation', :data_type => :text, :avm_group_id => 4 },
      { :id => 42, :tag_name => 'Spatial.CoordsystemProjection', :schema => 'avm:Spatial.CoordsystemProjection', :data_type => :text, :avm_group_id => 4 },
      { :id => 43, :tag_name => 'Spatial.Quality', :schema => 'avm:Spatial.Quality', :data_type => :text, :avm_group_id => 4 },
      { :id => 44, :tag_name => 'Spatial.Notes', :schema => 'avm:Spatial.Notes', :data_type => :alternatives, :avm_group_id => 4 },
      { :id => 45, :tag_name => 'Spatial.FITSheader', :schema => 'avm:Spatial.FITSheader', :data_type => :text, :avm_group_id => 4 },
      { :id => 46, :tag_name => 'Publisher', :schema => 'avm:Publisher', :data_type => :text, :avm_group_id => 5 },
      { :id => 47, :tag_name => 'PublisherID', :schema => 'avm:PublisherID', :data_type => :text, :avm_group_id => 5 },
      { :id => 48, :tag_name => 'ResourceID', :schema => 'avm:ResourceID', :data_type => :text, :avm_group_id => 5 },
      { :id => 49, :tag_name => 'ResourceURL', :schema => 'avm:ResourceURL', :data_type => :text, :avm_group_id => 5 },
      { :id => 50, :tag_name => 'RelatedResources', :schema => 'avm:RelatedResources', :data_type => :bag, :avm_group_id => 5 },
      { :id => 51, :tag_name => 'MetadataDate', :schema => 'avm:MetadataDate', :data_type => :text, :avm_group_id => 5 },
      { :id => 52, :tag_name => 'MetadataVersion', :schema => 'avm:MetadataVersion', :data_type => :text, :avm_group_id => 5 }
    ] )
  end

  def self.clear_xmp( filename )
    `exiftool -xmp:All= #{ filename }`
  end
  
# This is what this function might look like if we proceed with the python toolkit
=begin
  def self.read_xmp( filename )
    raise "Cannot find file for XMP extraction." unless File.file?( filename )
    
    xmp_psuedo_json = PythonXmpResource.find( :first, :params => { :path => filename } )
    @data = {}
    Avm.all.each do |avm|
      case avm.data_type
      when :text
        @data[ avm.name ] = xmp_psuedo_json.attributes[ avm.tag_name ].to_s
      when :iptc_contact
        @data[ avm.name ] = xmp_psuedo_json.attributes[ avm.tag_name ].to_s
      when :sequence
        @data[ avm.name ] = eval( xmp_psuedo_json.attributes[ avm.tag_name ] ).collect{ |li| li.to_s.utf8_to_ascii } if xmp_psuedo_json.attributes[ avm.tag_name ] # EVAL DANGER!!!
      when :bag
        @data[ avm.name ] = eval( xmp_psuedo_json.attributes[ avm.tag_name ] ).collect{ |li| li.to_s.utf8_to_ascii } if xmp_psuedo_json.attributes[ avm.tag_name ] # EVAL DANGER!!!
      when :alternatives
        @data[ avm.name ] = eval( xmp_psuedo_json.attributes[ avm.tag_name ] )[ 0 ].to_s.utf8_to_ascii if xmp_psuedo_json.attributes[ avm.tag_name ]# EVAL DANGER!!!
      end
    end
    return @data
  end
=end
#=begin
  def self.read_xmp( filename )
    raise "Cannot find file for XMP extraction." unless File.file?( filename )
    stdin, stdout, stderr = Open3.popen3 "exiftool -b -xmp #{ filename }"
    @xmp_doc = REXML::Document.new stdout.read
    @data = {}
    Avm.all.each do |avm|
      case avm.data_type
      when :text
        if Avm.good_avm_text?( @xmp_doc.root.elements[ "rdf:RDF/rdf:Description/" + avm.schema ] )
          @data[ avm.name ] = @xmp_doc.root.elements[ "rdf:RDF/rdf:Description/" + avm.schema ].text.utf8_to_ascii
        end
      when :iptc_contact
        if Avm.good_avm_text?( @xmp_doc.root.elements[ "rdf:RDF/rdf:Description//" + avm.schema ] )
          @data[ avm.name ] = @xmp_doc.root.elements[ "rdf:RDF/rdf:Description//" + avm.schema ].text.utf8_to_ascii
        end
      when :sequence
        unless @xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Seq/rdf:li" ).empty?
          @data[ avm.name ] = @xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Seq/rdf:li" ).select{ |li| Avm.good_avm_text?( li ) }.collect{ |li| li.text.utf8_to_ascii } 
        end
      when :bag
        unless @xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Bag/rdf:li" ).empty?
          @data[ avm.name ] = @xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Bag/rdf:li" ).select{ |li| Avm.good_avm_text?( li ) }.collect{ |li| li.text.utf8_to_ascii } 
        end
      when :alternatives
        if !@xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Alt/rdf:li" ).empty? &&
           Avm.good_avm_text?( @xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Alt/rdf:li" )[0] )
          # We only take the first Alt.  We do not handle other languages.
          @data[ avm.name ] = @xmp_doc.root.elements.to_a( "rdf:RDF/rdf:Description/" + avm.schema + "/rdf:Alt/rdf:li" )[0].text.utf8_to_ascii 
        end
      end
    end
    return @data
  end
#=end

  def self.write_xmp( filename, data )
    raise "Cannot find file for XMP writing." unless File.file?( filename )
    exiftool_temporary_filename = filename + '_exiftool_tmp'
    exiftool_original_filename = filename + '_original'
    @parameters = ""
    data.each do |avm_name, value|
      if ( ( avm = Avm.fetch( avm_name ) ) && !value.nil? && ( value != "undefined" ) ) 
        case avm.data_type
        when :text
          @parameters += " -xmp-#{ avm.schema }=\"#{ value.escape_for_exiftool }\""
        when :alternatives
          @parameters += " -xmp-#{ avm.schema }=\"#{ value.escape_for_exiftool }\""
#          @parameters += " -xmp-#{ avm.schema }-x-default=\"#{ value.escape_for_exiftool }\""
        when :sequence, :bag
          @parameters += ( value.collect{ |v|
            " -xmp-#{ avm.schema }+=\"#{ v.escape_for_exiftool }\""
          } * "" )
        when :iptc_contact
          @parameters += " -xmp-iptcCore:CreatorContactInfo#{ avm.schema.split( ":" )[1] }=\"#{ value.escape_for_exiftool }\""
        end
      end
    end

    # No blocking, please.
    File.delete exiftool_temporary_filename if File.exists?( exiftool_temporary_filename )
    # Make a run for it.
    stdin, stdout, stderr = Open3.popen3 "exiftool#{ @parameters } #{ filename }"
    # Like a ninja, we leave no trace.
    File.delete exiftool_original_filename if File.exists?( exiftool_original_filename )
    
    return stdout.readlines.include?( "    1 image files updated\n" )
  end

  def avm_group
    AvmGroup.fetch( avm_group_id )
  end
  
  def name
    tag_name.gsub( '.', '_' ).downcase
  end
  
  def self.good_avm_text?( xml_node )
    !( xml_node.nil? || xml_node.text.nil? || ( xml_node.text == "undefined" ) )
  end

end

