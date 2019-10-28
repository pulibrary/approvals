# frozen_string_literal: true
class DelegatesController < ApplicationController
  before_action :set_delegate, only: [:show, :edit, :update, :destroy]
  before_action :set_delegator, only: [:assume]

  # GET /delegates
  # GET /delegates.json
  def index
    @delegates = Delegate.where(delegator: current_staff_profile)
  end

  # GET /delegates/1
  # GET /delegates/1.json
  def show
    return if @delegate.present?

    respond_to do |format|
      format.html { redirect_to delegates_path, notice: "invalid delegate" }
      format.json { head :no_content }
    end
  end

  # GET /delegates/new
  def new
    @delegate = Delegate.new
  end

  # GET /delegates/1/edit
  def edit; end

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
        format.html { redirect_to @delegate, notice: "Delegate was successfully created." }
        format.json { render :show, status: :created, location: @delegate }
      else
        format.html { render :new }
        format.json { render json: @delegate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delegates/1
  # PATCH/PUT /delegates/1.json
  def update
    respond_to do |format|
      if @delegate.update(delegate_params)
        format.html { redirect_to @delegate, notice: "Delegate was successfully updated." }
        format.json { render :show, status: :ok, location: @delegate }
      else
        format.html { render :edit }
        format.json { render json: @delegate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delegates/1
  # DELETE /delegates/1.json
  def destroy
    @delegate.destroy
    respond_to do |format|
      format.html { redirect_to delegates_url, notice: "Delegate was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

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
