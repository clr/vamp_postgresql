class AvmTag < ActiveRecord::Base
  belongs_to :image

  def avm
    Avm.fetch( self.avm_id )
  end

  def avm=( avm_instance )
    case avm_instance.class.name
    when "Avm"
      self.avm_id = avm_instance.id
    when "Fixnum"
      self.avm_id = avm_instance
    end
  end
  
  def visible_image_set
    if !self.image.nil? && !self.image.attachable.nil? && self.image.attachable.workflow == Workflow.published && self.image.attachable.display == Display.visible
      self.image.attachable
    else
      nil
    end
  end

  def visible_vm_image_set
    if !self.image.nil? && !self.image.attachable.nil? && self.image.attachable.workflow == Workflow.published && self.image.attachable.display == Display.visible && self.image.attachable.virtual_museum
      self.image.attachable
    else
      nil
    end
  end

end
