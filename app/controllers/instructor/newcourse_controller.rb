class Instructor::NewcourseController < Instructor::InstructorBase

  before_filter :ensure_logged_in, :ensure_instrctur_or_admin

  layout 'noright'

  def index    
    set_title()
    initialize_with_term(@current_term)
    @term = @current_term
  end

  def change_term
    set_title()
    
    @term = Term.find(params[:id])
    initialize_with_term(@term)
    render :action => 'index'
  end

  def create
    crnsToAdd = Array.new
    ## Possibly add any other CRNs by id.
    params.keys.each do |key|
      if (key.starts_with?('crn_'))
        crnId = key[4..-1].to_i
        crn = Crn.find(crnId)
        if !crn.nil?
          crnsToAdd << crn
        end
      end
    end

    createNoneCrn = crnsToAdd.empty?
    @course = Course.create_course(params[:course], params[:term], params[:crn], createNoneCrn)
    ## Add in the empty CRNs
    crnsToAdd.each { |c| @course.crns << c }

    if @course.save
      c = CoursesUser.new
      c.course = @course
      c.user = @user
      c.course_student = false
      c.course_instructor = true
      c.term_id = @course.term_id
      c.save
      
      flash[:notice] = "New course '#{@course.title}' has been created."
      redirect_to :controller => '/instructor/index', :course => @course
    else
      flash[:badnotice] = "Course create failed."
      @terms = Term.find(:all)
      @crn = params[:crn]
      render :action => 'index'
    end
  end

private
  def initialize_with_term(term)
    @terms = Term.find(:all)
    @course = Course.new
    @course.term = term
    @crn = ''

    #if @isLdap
      # load the CRNs for the current term
      @allCrns = Crn.find(:all, :conditions => ["crn like ?", "#{@term.term}%" ])
      size = @allCrns.size / 2
      @column1 = Array.new
      0.upto(size) { |i| @column1 << @allCrns[i] }
      @column2 = Array.new
      (size+1).upto(@allCrns.size-1) { |i| @column2 << @allCrns[i] }
    #end
  end

  def set_title
    @title = "Create a new course"
    @current_term = Term.find_current
    @isLdap = is_using_ldap()
  end
  
end
