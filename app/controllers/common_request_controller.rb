# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class CommonRequestController < ApplicationController
  # GET
  def show
    # you may view the request only if you are the creator, or you are allowed to review the request
    if allowed_to_review || allowed_read_only || current_staff_profile == @request.creator
      @request = request_decorator_class.new(@request)

    else
      respond_to do |format|
        @request = nil
        format.html do
 redirect_to my_requests_path, flash: { error: "Only the requestor or reviewer can view a request" }
        end
        format.json { redirect_to my_requests_path(format: :json) }
      end
    end
  end

  # GET
  def new
    # the sync is required since the form currently runs off of the change set model
    # prepopulate creates a default unsaved request event
    # Reform 2.6.2 throws an error unless you send a Hash with at least one key in it
    # to prepopulate!, although this is not in the documentation for Reform.
    request_change_set.prepopulate!({ _unused_value: nil }).sync
  end

  # GET
  def edit
    @request_change_set = request_change_set

    # render the default
    return if request_change_set.can_modify_attributes? && current_staff_profile == request_change_set.creator

    # handle the error
    error = if current_staff_profile == request_change_set.creator
              "#{model_instance_to_name(@request_change_set.model)} can not be edited after it has been #{@request_change_set.model.status}."
            else
              "You must be the creator to edit a request"
            end
    respond_with_show_error(message: error, status: :invalid_edit)
  end

  # POST
  def create
    MailForAction.send(request: @request, action: "create") if update_model_and_respond(handle_deletes: false,
                                                                                        success_verb: "created", error_action: :new)
  end

  # PATCH/PUT
  def update
    if request_change_set.can_modify_attributes?
      update_model_and_respond(handle_deletes: true, success_verb: "updated", error_action: :edit)
    else
      respond_with_show_error(message: "#{model_instance_to_name(@request_change_set.model)} can not be updated after it has been #{@request_change_set.model.status}.",
                              status: :invalid_update)
    end
  end

  # DELETE
  def destroy
    @request.destroy
    respond_to do |format|
      format.html do
 redirect_to list_url, flash: { success: "#{model_instance_to_name(@request)} was successfully destroyed." }
      end
      format.json { head :no_content }
    end
  end

  # GET
  def review
    @request_change_set = request_change_set

    # render the default
    return true if @request_change_set.model.pending? && allowed_to_review

    message = if allowed_to_review
                "#{model_instance_to_name(@request)} can not be reviewed after it has been #{@request_change_set.model.status}."
              else
                "You are not allowed access to review this #{model_instance_to_name(@request)}"
              end

    # handle the error
    respond_with_show_error(message:, status: :invalid_edit)
  end

  def comment
    @request_change_set = request_change_set

    # render the default
    return true if @request_change_set.model.only_creator_or_supervisor?(agent: current_staff_profile)

    message = "You are not allowed access to comment on this #{model_instance_to_name(@request)}"

    # handle the error
    respond_with_show_error(message:, status: :invalid_edit)
  end

  # PATCH/PUT
  def decide
    validate_for_action
    if params[:approve]
      run_action(action: :approve, change_method: :supervisor_can_change?)
    elsif params[:deny]
      run_action(action: :deny, change_method: :supervisor_can_change?)
    elsif params[:cancel]
      run_action(action: :cancel, change_method: :creator_can_cancel?)
    elsif params[:comment]
      update_model_and_respond(handle_deletes: false, success_verb: "Commented On", error_action: :comment)
    end
  end

  private

    # The #validate method removes any existing errors that we've added manually.
    # If we need to manually add errors, add them to this pending_errors array, and
    # then we can add them to the errors list after calling #validate, allowing them
    # to persist.
    def pending_errors
      @pending_errors ||= []
    end

    def validate_for_action
      if params[:deny] && processed_params[:notes].blank?
        pending_errors.push({ attribute: :notes, type: "are required to deny a request" })
      elsif params[:comment] && processed_params[:notes].blank?
        pending_errors.push({ attribute: :notes, type: "are required to comment on a request" })
      end
    end

    def allowed_to_review
      @allowed_to_review ||= @request.only_supervisor(agent: current_staff_profile)
    end

    def allowed_read_only
      @allowed_read_only ||= @request.creator.department.admin_assistants&.include? current_staff_profile
    end

    def process_notes(notes)
      if current_staff_profile.current_delegate.present? && action_name == "create"
        delegate_note_hash = { creator_id: current_staff_profile.current_delegate.id,
                               content: "This request was created by #{current_staff_profile.current_delegate.full_name} on behalf of #{current_staff_profile.full_name}" }
      end
      return [delegate_note_hash].compact unless notes

      Array(notes).map do |note_entry|
        note_entry.merge(creator_id: current_staff_profile.id) if note_entry[:content].present?
      end.prepend(delegate_note_hash).compact
    end

    def respond_with_show_error(message:, status:)
      respond_to do |format|
        @request = request_change_set.model
        format.html { redirect_to @request, flash: { error: message } }
        format.json { render :show, status:, location: @request }
      end
      false
    end

    def handle_nested_deletes
      true
    end

    def model_instance_to_name(model)
      model.class.name.underscore.humanize
    end

    def setup_change_set_for_view
      clear_error_data
      copy_model_errors_to_change_set
      sync_data_to_model
    end

    def sync_data_to_model
      note = request_change_set.notes.last.dup unless request_change_set.notes.blank? || request_change_set.notes.empty?
      request_change_set.sync(exclude: ["notes"])
      request_change_set.model.notes << Note.new(content: note.content) unless note.blank? || note.id.present?
    end

    # change set does not implement each_key, which this rubocop error is requesting
    def copy_model_errors_to_change_set
      request_change_set.model.errors.each do |error|
        request_change_set.errors.add(error.attribute, error.message)
      end
    end

    def clear_error_data
      request_change_set.errors.each do |error|
        next if error.attribute.to_s.include?(".") # skip clearing nested objects

        request_change_set.send("#{error.attribute}=", nil)
      end
    end

        def update_model_and_respond(handle_deletes:, success_verb:, error_action:)
      valid = validate_and_save(handle_deletes:)
      respond_to do |format|
        if valid
          @request = request_change_set.model
          format.html do
 redirect_to @request, flash: { success: "#{model_instance_to_name(@request)} was successfully #{success_verb}." }
          end
          format.json { render :show, status: :ok, location: @request }
        else
          setup_change_set_for_view
          format.html { render error_action }
          format.json { render json: request_change_set.errors, status: :unprocessable_entity }
        end
      end
      valid
        end

    def validate_and_save(handle_deletes:)
      params_to_process = if process_request_params?
                            processed_params
                          else
                            {}
                          end
      valid = request_change_set.validate(params_to_process) && pending_errors.empty?
      pending_errors.each do |error|
        request_change_set.errors.add(error[:attribute], error[:type])
      end
      handle_nested_deletes if valid && handle_deletes
      valid && request_change_set.save
    end

    def run_action(action:, change_method: :creator_can_change?)
      allowed_to_change = send(change_method, action:)
      return unless allowed_to_change

      request = request_change_set.model
      request.aasm.fire(action, agent: current_staff_profile) if request_change_set.valid?

      MailForAction.send(request:, action:) if update_model_and_respond(handle_deletes: false,
                                                                        success_verb: "updated", error_action: :review)
    end

    def creator_can_change?(action:)
      allowed_to_change = request_change_set.model.can_edit?(agent: current_staff_profile)
      respond_to_change_error(action:, allowed_to_change:)
    end

    def creator_can_cancel?(action:)
      allowed_to_change = request_change_set.model.can_cancel?(agent: current_staff_profile)
      respond_to_change_error(action:, allowed_to_change:)
    end

    def supervisor_can_change?(action:)
      allowed_to_change = request_change_set.model.only_supervisor(agent: current_staff_profile)
      respond_to_change_error(action:, allowed_to_change:)
    end

    def can_comment?(action:)
      allowed_to_change = request_change_set.model.only_creator_or_supervisor?(agent: current_staff_profile)
      respond_to_change_error(action:, allowed_to_change:)
    end

    def respond_to_change_error(action:, allowed_to_change:)
      return allowed_to_change if allowed_to_change

      respond_to do |format|
        @request = request_change_set.model
        format.html { redirect_to @request, flash: { error: "You are not allowed access to #{action} this request" } }
        format.json { render :show, status: :invalid_review, location: @request }
      end
      allowed_to_change
    end
end
