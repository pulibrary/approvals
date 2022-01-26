# frozen_string_literal: true
class DelegatesController < ApplicationController
  before_action :set_delegate, only: [:destroy]
  before_action :set_delegator, only: [:assume]
  before_action :check_for_delegation, only: [:assume, :create, :destroy]

  # GET /delegates
  # GET /delegates.json
  def index
    delegates_for_current_profile
    @delegate = Delegate.new
    @staff_list = current_staff_profile.staff_list_json
  end

  # GET /delegates/to_assume
  # GET /delegates/to_assume.json
  def to_assume
    @delegators = Delegate.joins(:delegator).where(delegate: current_staff_profile).order("staff_profiles.surname")
  end

  # GET /delegates/1/assume
  def assume
    if @delegate && (@delegate.delegate == current_staff_profile)
      session[:approvals_delegate] = @delegate.id.to_s
      flash[:success] = "You are now acting on behalf of #{@delegate.delegator}"
    else
      session[:approvals_delegate] = nil
      flash[:error] = "Invalid delegation attempt!"
    end
    respond_to do |format|
      format.html { redirect_to my_requests_path }
      format.json { head :no_content }
    end
  end

  # GET /delegates/cancel
  def cancel
    session[:approvals_delegate] = nil
    respond_to do |format|
      format.html { redirect_to my_requests_path, flash: { success: "You are now acting on your own behalf" } }
      format.json { head :no_content }
    end
  end

  # POST /delegates
  # POST /delegates.json
  def create
    @delegate = Delegate.new(delegate_params)

    respond_to do |format|
      if @delegate.save
        format.html { redirect_to delegates_path, flash: { success: "Delegate was successfully created." } }
        format.json { render :show, status: :created, location: @delegate }
      else
        delegates_for_current_profile
        format.html { render :index }
        format.json { render json: @delegate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delegates/1
  # DELETE /delegates/1.json
  def destroy
    if @delegate.blank?
      flash[:error] = "Invalid delegate #{params[:id]} can not be destroyed"
    else
      @delegate.destroy
      flash[:success] = "Delegate was successfully destroyed."
    end
    respond_to do |format|
      format.html { redirect_to delegates_url }
      format.json { head :no_content }
    end
  end

  private

  def delegates_for_current_profile
    @delegates = Delegate.joins(:delegate).where(delegator: current_staff_profile).order("staff_profiles.surname")
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_delegate
    @delegate = Delegate.find(params[:id])
    @delegate = nil if @delegate.delegator != current_staff_profile
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def set_delegator
    @delegate = Delegate.find(params[:id])
    @delegate = nil if @delegate.delegate != current_staff_profile
  rescue ActiveRecord::RecordNotFound
    nil
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def delegate_params
    permitted_params = params.require(:delegate).permit(:delegate_id)

    # the delegator can only be the logged in user
    permitted_params.merge(delegator_id: current_staff_profile.id)
  end

  def check_for_delegation
    return unless current_delegate

    respond_to do |format|
      format.html { redirect_to my_requests_path, flash: { error: "You can not modify delegations as a delegate" } }
      format.json { head :no_content }
    end
    false
  end
end
