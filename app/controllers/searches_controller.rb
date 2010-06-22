class SearchesController < ApplicationController

  def get
    @results = []
  end

  def post
    # Search term entered.
    if ( params[:by_type] && params[:by_type].length > 0 )
      @type_conditions = []
      type_table = {
        'astronomical' => [ "'Observation'", "'Planetary'", "'Collage'" ],
        'artwork' => [ "'Artwork'" ],
        'spectra' => [ "'Chart'", "'Simulation'" ],
        'photographs' => [ "'Photograph'" ]
      }
      params[:by_type].split( ':' ).each do |image_type|
        @type_conditions = @type_conditions + type_table[ image_type ]
      end
      @image_type_conditions = "( value IN (#{ @type_conditions * ',' }) AND avm_id=23 )"
      @type_tag_ids = AvmTag.find( :all, :conditions => @image_type_conditions ).collect( &:visible_image_set ).reject{ |i| i.nil? }.uniq.collect( &:id )
    end
    if ( params[:by_subject] && params[:by_subject].length > 0 )
      subject_table = {
        'planet' => "value LIKE '_.1",
        'comets' => "value LIKE '_.2",
        'star' => "value LIKE '_.3",
        'nebula' => "value LIKE '_.4",
        'galaxy' => "value LIKE '_.5",
        'cosmology' => "value LIKE '_.6",
        'technology' => "value LIKE '_.8",
        'mission' => "value LIKE '_.10"
      }
      @by_subject_parts = params[:by_subject].split( '.' )
      if subject_table[ @by_subject_parts[0] ].nil?
        @image_subject_conditions = "( false )"
      elsif @by_subject_parts.length == 1
        @image_subject_conditions = "( avm_id=15 AND ( #{ subject_table[ @by_subject_parts[0] ] }%' ) )"
      elsif @by_subject_parts.length == 2
        @image_subject_conditions = "( avm_id=15 AND ( #{ subject_table[ @by_subject_parts[0] ] }.#{ @by_subject_parts[1].to_i }%' ) )"
      else
        @image_subject_conditions = "( avm_id=15 AND ( #{ subject_table[ @by_subject_parts[0] ] }.#{ @by_subject_parts[1].to_i }.#{ @by_subject_parts[2].to_i }%' ) )"
      end
      @subject_tag_ids = AvmTag.find( :all, :conditions => @image_subject_conditions ).collect( &:visible_image_set ).reject{ |i| i.nil? }.uniq.collect( &:id )
    end
    
    if @type_tag_ids || @subject_tag_ids
      if @type_tag_ids.nil? || @type_tag_ids.empty?
        @tagged_image_ids = @subject_tag_ids
      elsif @subject_tag_ids.nil? || @subject_tag_ids.empty?
        @tagged_image_ids = @type_tag_ids
      else
        @tagged_image_ids = @type_tag_ids & @subject_tag_ids
      end
      if @tagged_image_ids.empty?
        @objects = [].paginate :page => params[:page], :per_page => params[:limit]
      elsif params[:search] && parse_search.length > 0
        @objects = ImageSet.visible.image_gallery_curated.by_date.find_by_tsearch( parse_search, :conditions => "id IN (#{ @tagged_image_ids * ',' })" ).paginate :page => params[:page], :per_page => params[:limit]
        @counts_by_resource = { :image_set => @objects.total_entries }
        allowed_resources.each do |allowed_resource|
          @counts_by_resource[ allowed_resource.to_sym ] ||= allowed_resource.camelize.constantize.visible.find_by_tsearch( parse_search ).length
        end unless ( params[:tabs] == 'hidden' )
      else
        # Can we assume that we are coming from Page._images?
        @search_tabs = nil
        @objects = ImageSet.visible.image_gallery_curated.by_date.find( :all, :conditions => "id IN(#{ @tagged_image_ids * ',' })" ).paginate :page => params[:page], :per_page => params[:limit]
      end
    else
      @tags = AvmTag.connection.select_all(<<-SQL
        SELECT attachments.attachable_id 
          AS image_set_ids
          FROM avm_tags
            JOIN attachments
            ON avm_tags.image_id=attachments.id
          WHERE avm_id=#{params[:type]}
            AND value ~* '#{params[:search]}'
            AND attachments.type='Image'
            AND attachments.attachable_type='ImageSet'
        SQL
      )
      @image_set_ids = @tags.collect{|t| t['image_set_ids']}
      #raise @image_set_ids.inspect
      @results = ImageSet.where(:id => @image_set_ids, :workflow_id => Workflow.published.id, :display_id => Display.visible.id)
    end
    render :get
  end

  protected
    def prepare_restful_interpretation
      case params[:grammatical_number]
      when 'plural'
        self.action_name = self.request.request_method.to_s.pluralize
      when 'singular'
        params[:resource] ||= allowed_resources[0]
        self.action_name = self.request.request_method.to_s.singularize
      end
    end
    
    # Put search conditions in here.
    def parse_search
      @parse_search ||= ActiveRecord::Base.connection.quote_string( params[:search] || "" )
    end

    def resource_types
      [ 
        [ :image_set, "Images" ],
        [ :video_set, "Video & Audio" ],
        [ :fyle, "Downloads" ],
        [ :news_item, "News" ],
        [ :blog, "Blog Posts" ],
        [ :page, "Pages" ]
      ]
    end
    
    def allowed_resources
      %w( image_set news_item video_set fyle blog page )
    end
end
