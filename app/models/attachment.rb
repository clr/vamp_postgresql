class Attachment < ActiveRecord::Base

  # This is clearly not tuned for performance.
  def clone
    new_attachment = super
    new_attachment.save
    file_path = File.join( RAILS_ROOT, 'public', self.public_filename )
    file = Tempfile.new( filename )
    File.copy(file_path, file.path)
    file.open
    file.class.send( :define_method, :content_type, lambda{ new_attachment.content_type } )
    file.class.send( :define_method, :original_filename, lambda{ new_attachment.filename } )
    file.class.send( :define_method, :file_path, lambda{ self.path } ) 
    new_attachment.uploaded_data = file
    new_attachment.save
    return new_attachment
  end

end
