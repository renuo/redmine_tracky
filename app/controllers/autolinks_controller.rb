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
end
