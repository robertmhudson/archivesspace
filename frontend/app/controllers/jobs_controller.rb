class JobsController < ApplicationController

  set_access_control "view_repository" => [:index, :show, :log]
  set_access_control "update_archival_record" => [:new, :create]
  set_access_control "cancel_importer_job" => [:cancel]

  skip_before_filter :verify_authenticity_token


  def index
    @active_jobs = Job.active
    @search_data = Job.archived(selected_page)
  end

  def new
    @job = JSONModel(:job).new._always_valid!
  end

  def create
    job = Job.new(params['job']['import_type'], Hash[params['files'].map {|file|
                                [file.original_filename, file.tempfile]
                              }])

    render :json => job.upload
  end


  def show
    @job = JSONModel(:job).find(params[:id], "resolve[]" => "repository")
  end


  def cancel
    @job = JSONModel(:job).find(params[:id], "resolve[]" => "repository")

    # TODO: Cancel the @job

    redirect_to :action => :show
  end


  def log
    self.response_body = Enumerator.new do |y|
      Job.log(params[:id], params[:offset] || 0) do |response|
        y << response.body
      end
    end
  end


  private

  def selected_page
    [Integer(params[:page] || 1), 1].max
  end

end
