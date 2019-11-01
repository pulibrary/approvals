# frozen_string_literal: true
class CommonRequestController < ApplicationController
  # GET
  def show
    @request = request_decorator_class.new(@request)
  end

  # GET
  def new
    # the sync is required since the form currently runs off of the change set model
    # prepopulate creates a default unsaved request event
    request_change_set.prepopulate!.sync
  end

  # GET
  def edit
    @request_change_set = request_change_set

    # render the default
    return if can_edit?

    # handle the error
    respond_with_show_error(message: "#{model_instance_to_name(@request_change_set.model)} can not be edited after it has been #{@request_change_set.model.status}.",
                            status: :invalid_edit)
  end

  # POST
  def create
    update_model_and_respond(handle_deletes: false, success_verb: "created", error_action: :new)
  end

  # PATCH/PUT
  def update
    update_model_and_respond(handle_deletes: true, success_verb: "updated", error_action: :edit)
  end

  # DELETE
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to list_url, notice: "#{model_instance_to_name(@request)} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET
  def review
    @request_change_set = request_change_set
    allowed_to_review = @request_change_set.model.only_supervisor(agent: current_staff_profile)

    # render the default
    return if @request_change_set.model.pending? && allowed_to_review

    message = if allowed_to_review
                "#{model_instance_to_name(@request)} can not be reviewed after it has been #{@request_change_set.model.status}."
              else
                "You are not allowed access to review this #{model_instance_to_name(@request)}"
              end

    # handle the error
    respond_with_show_error(message: message, status: :invalid_edit)
  end

  # PATCH/PUT
  def decide
    if params[:approve]
      supervisor_action(action: :approve)
    elsif params[:deny]
      request_change_set.errors.add(:notes, "Notes are required to deny a request") if processed_params[:notes].blank?
      supervisor_action(action: :deny)
    end
  end

  private

    def process_notes(notes)
      return notes unless notes
      Array(notes).map do |note_entry|
        note_entry.merge(creator_id: current_staff_profile.id) if note_entry[:content].present?
      end.compact
    end

    def respond_with_show_error(message:, status:)
      respond_to do |format|
        @request = request_change_set.model
        format.html { redirect_to @request, notice: message }
        format.json { render :show, status: status, location: @request }
      end
    end

    def handle_nested_deletes
      true
    end

    def model_instance_to_name(model)
      model.class.name.underscore.humanize
    end

    def copy_model_errors_to_change_set
      request_change_set.model.errors.each do |key, value|
        @request_change_set.errors.add(key, value)
      end
    end

    def update_model_and_respond(handle_deletes:, success_verb:, error_action:)
      valid = request_change_set.validate(processed_params)
      handle_nested_deletes if valid && handle_deletes
      valid &&= request_change_set.save

      respond_to do |format|
        if valid
          @request = request_change_set.model
          format.html { redirect_to @request, notice: "#{model_instance_to_name(@request)} was successfully #{success_verb}." }
          format.json { render :show, status: :ok, location: @request }
        else
          copy_model_errors_to_change_set
          format.html { render error_action }
          format.json { render json: request_change_set.errors, status: :unprocessable_entity }
        end
      end
    end

    def supervisor_action(action:)
      allowed_to_change = can_change?(action: action)
      return unless allowed_to_change

      request = request_change_set.model
      request.aasm.fire(action, agent: current_staff_profile) if request_change_set.valid?

      update_model_and_respond(handle_deletes: false, success_verb: request.status, error_action: :review)
    end

    def can_change?(action:)
      allowed_to_change = request_change_set.model.only_supervisor(agent: current_staff_profile)
      return allowed_to_change if allowed_to_change

      respond_to do |format|
        @request = request_change_set.model
        format.html { redirect_to @request, notice: "You are not allowed access to #{action} this absence" }
        format.json { render :show, status: :invalid_review, location: @request }
      end
      allowed_to_change
    end
end
