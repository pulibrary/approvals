# frozen_string_literal: true
class StaffProfilesController < ApplicationController
  before_action :set_staff_profile, only: [:show, :edit, :update, :destroy]

  # GET /staff_profiles
  # GET /staff_profiles.json
  def index
    @staff_profiles = StaffProfile.all
  end

  # GET /staff_profiles/1
  # GET /staff_profiles/1.json
  def show; end

  # GET /staff_profiles/new
  def new
    @staff_profile = StaffProfile.new
  end

  # GET /staff_profiles/1/edit
  def edit; end

  # POST /staff_profiles
  # POST /staff_profiles.json
  def create
    @staff_profile = StaffProfile.new(staff_profile_params)

    respond_to do |format|
      if @staff_profile.save
        format.html { redirect_to @staff_profile, notice: "Staff profile was successfully created." }
        format.json { render :show, status: :created, location: @staff_profile }
      else
        format.html { render :new }
        format.json { render json: @staff_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staff_profiles/1
  # PATCH/PUT /staff_profiles/1.json
  def update
    respond_to do |format|
      if @staff_profile.update(staff_profile_params)
        format.html { redirect_to @staff_profile, notice: "Staff profile was successfully updated." }
        format.json { render :show, status: :ok, location: @staff_profile }
      else
        format.html { render :edit }
        format.json { render json: @staff_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_profiles/1
  # DELETE /staff_profiles/1.json
  def destroy
    @staff_profile.destroy
    respond_to do |format|
      format.html { redirect_to staff_profiles_url, notice: "Staff profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_staff_profile
      @staff_profile = StaffProfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staff_profile_params
      params.require(:staff_profile).permit(:user_id, :department_id, :supervisor, :biweekly)
    end
end
