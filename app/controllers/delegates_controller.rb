# frozen_string_literal: true
class DelegatesController < ApplicationController
  before_action :set_delegate, only: [:destroy]
  before_action :set_delegator, only: [:assume]

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
    @delegators = Delegate.where(delegate: current_staff_profile)
  end

  # GET /delegates/1/assume
  def assume
    if @delegate && (@delegate.delegate == current_staff_profile)
      session[:approvals_delegate] = @delegate.id.to_s
      message = "You are now acting on behalf of #{@delegate.delegator}"
    else
      session[:approvals_delegate] = nil
      message = "Invalid delegation attempt!"
    end
    respond_to do |format|
      format.html { redirect_to my_requests_path, notice: message }
      format.json { head :no_content }
    end
  end

  # GET /delegates/cancel
  def cancel
    session[:approvals_delegate] = nil
    respond_to do |format|
      format.html { redirect_to my_requests_path, notice: "You are now acting on your own behalf" }
      format.json { head :no_content }
    end
  end

  # POST /delegates
  # POST /delegates.json
  def create
    @delegate = Delegate.new(delegate_params)

    respond_to do |format|
      if @delegate.save
        format.html { redirect_to delegates_path, notice: "Delegate was successfully created." }
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
    notice = if @delegate.blank?
               "Invalid delegate #{params[:id]} can not be destroyed"
             else
               @delegate.destroy
               "Delegate was successfully destroyed."
             end
    respond_to do |format|
      format.html { redirect_to delegates_url, notice: notice }
      format.json { head :no_content }
    end
  end

  private

    def delegates_for_current_profile
      @delegates = Delegate.where(delegator: current_staff_profile)
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
end
