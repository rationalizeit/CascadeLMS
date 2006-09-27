class Assignment < ActiveRecord::Base
  belongs_to :course
  acts_as_list :scope => :course
  
  belongs_to :grade_category
  has_one :journal_field, :dependent => :destroy
  
  has_many :assignment_documents, :order => "position", :dependent => :destroy
  has_many :user_turnins, :order => "user_id asc, position desc", :dependent => :destroy
  
  has_many :journals, :dependent => :destroy
  
  has_one :grade_item
  
  validates_presence_of :title
  # NEEDS extended validations
  # open < due <= close dates
  # either (1) description or (2) file uploads
  # if a SVN path is given, that is is appropriate 
  
  before_save :transform_markup
  
  def summary_date
    open_date.to_date.to_formatted_s(:short)
  end
  
  def feed_action
    "Assignment Posted"
  end
  
  def acronym
     'Assignment'
  end
  
  def summary_title
    self.title
  end
  
  def summary_actor
    due_date.to_formatted_s(:friendly_date)
  end
  
  def summary_action
    'due'
  end
  
  def icon
    'calendar'
  end
  
  def upcoming?
    Time.now < open_date
  end
  
  def current?
    td = Time.now
    open_date <= td && td <= due_date
  end
  
  def development_path_replace( uniqueid )
    subversion_development_path.gsub(/\$uniqueid\$/, uniqueid )
  end
 
  def release_path_replace( uniqueid )
    subversion_release_path.gsub(/\$uniqueid\$/, uniqueid )
  end
  
  def past?
    Time.now > due_date
  end
  
  def closed?
    Time.now > close_date
  end
  
  def validate
    errors.add_to_base( 'The assignment available date must be before the assignment close date' ) unless close_date > open_date
    errors.add_to_base( 'The assinment due date must be before the assignment close date and after the available date.') unless close_date >= due_date || due_date <= open_date
   
    if ! self.file_uploads && (self.description.nil?  || self.description.size == 0)
      errors.add('description', 'can not be empty if you are not uploading a file.')
    end
   
    if self.programming && self.use_subversion
      errors.add('subversion_server', 'can not be empty when using subversion.') if subversion_server.nil? || subversion_server.size == 0
      errors.add('subversion_development_path', 'can not be empty when using subversion.') if subversion_development_path.nil? 
    end
   
  end
  
  def transform_markup
	  self.description_html = HtmlEngine.apply_textile( self.description ) unless self.description.nil?
  end
  
  protected :transform_markup
  
  
end