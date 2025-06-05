# frozen_string_literal: true

class AutolinksController < TrackyController
  before_action :set_project
  before_action :set_autolink, only: %i[edit update]

  def index
  end

  def new
    @autolink = Autolink.new(project: @project)
  end

  def edit
  end

  def create
    @autolink = Autolink.new(**autolink_params, project: @project)

    if @autolink.save
      redirect_to project_autolinks_path(@project)
    else
      render :new
    end
  end

  def update
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_autolink
    @autolink = Autolink.find_by(id: params[:id], project: @project)
  end

  def autolink_params
    params.require(:autolink).permit(:prefix, :target_url)
  end
end
