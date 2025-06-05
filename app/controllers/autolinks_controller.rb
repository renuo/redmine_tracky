# frozen_string_literal: true

class AutolinksController < TrackyController
  before_action :set_project
  before_action :set_autolink, only: %i[edit update destroy]

  def index
    @autolinks = Autolink.where(project: @project)
  end

  def new
    @autolink = Autolink.new(project: @project)
  end

  def create
    @autolink = Autolink.new(**autolink_params, project: @project)

    if @autolink.save
      redirect_to project_autolinks_path
    else
      render :new
    end
  end

  def update
    if @autolink.update(autolink_params)
      redirect_to project_autolinks_path
    else
      render :edit
    end
  end

  def destroy
    @autolink.destroy!
    redirect_to project_autolinks_path
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
