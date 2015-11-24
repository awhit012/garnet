class AssignmentsController < ApplicationController
  before_action :authorize_admin, only: [:show]

  # TODO: pretty sure this is dead code, nothing in routes.rb routes to it -AB
  def index
    @group = Group.at_path(params[:group_path])
    @users = @group.nonadmins
    @is_admin = @group.admins.include?(current_user)
    @assignment = Assignment.new(group_id: @group)
    @assignments = @group.descendants_attr("assignments")
    @submissions = @group.descendants_attr("submissions")
  end

  def show
    @assignment = Assignment.find(params[:id])
    @group = Group.at_path(params[:group]) || @assignment.group
    @submissions = @assignment.submissions.select{|s| s.user.is_member_of(@group) }
    @submissions.sort_by!{|s| s.user.last_name}

    @show_inactive = params[:show_inactive] == "true"
    @show_na = params[:show_na] == "true"

    unless @show_inactive
      @submissions = @submissions.select{|s| s.user.memberships.find_by(group: @group).active? }
    end

    if @show_na
      @submissions = @submissions.select{|s| s.status == nil }
    end
  end

  def create
    @group = Group.at_path(params[:group_path])
    @assignment = @group.assignments.new(assignment_params)
    if @assignment.save
      redirect_to assignment_path(@assignment)
    end
  end

  def update
    @assignment = Assignment.find(params[:id])
    @assignment.update(assignment_params)
    redirect_to assignment_path(@assignment)
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy!
    redirect_to @assignment.group
  end

  def issues
    @assignment = Assignment.find(params[:assignment_id])
    render json: @assignment.issues
  end

  private
    def assignment_params
      params.require(:assignment).permit(:title, :category, :repo_url, :due_date)
    end

    def authorize_admin
      @assignment = Assignment.find(params[:id])

      is_admin = @assignment.group.has_admin?(current_user)
      if !is_admin
        redirect_to(current_user, flash:{alert: "You're not authorized."}) and return
      end
    end

end
