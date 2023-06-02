# frozen_string_literal: true
class TravelRequestDecorator < RequestDecorator
  delegate :participation, :purpose, :event_requests, :event_format, :estimates,
           :status, :can_modify_attributes?, to: :request
  delegate :full_name, :department, to: :creator
  attr_reader :travel_request

  def initialize(travel_request)
    super(travel_request)
    @request = travel_request
  end

  def estimates_json
    estimate_list = []
    grand_total = 0
    estimates.each do |estimate|
      estimate_list.append(estimate_to_hash(estimate: estimate))
      grand_total += estimate.recurrence * estimate.amount
    end

    estimate_list.append(
      cost_type: "",
      note: "",
      recurrence: "",
      amount: "Total:",
      total: format("%.2f", grand_total)
    )

    estimate_list.to_json
  end

  def estimate_fields_json
    "[{ 'name': 'cost_type', 'display_name': 'Expense Type' },
      { 'name': 'note', 'display_name': 'Note' },
      { 'name': 'recurrence', 'display_name': 'Occurrences', 'datatype': 'number' },
      { 'name': 'amount', 'display_name': 'Cost per Occurrence', 'datatype': 'currency' },
      { 'name': 'total', 'display_name': 'Total', 'datatype': 'currency' } ]"
  end

  def travel_category_icon
    "lux-icon-globe"
  end

  def event_attendees
    @attendees ||= list_event_attendees
    @attendees << "No others attending" if @attendees.blank?
    @attendees
  end

  def event_title_brief
    request.event_title
  end

  def event_title
    "#{request.event_title} (#{event_dates})"
  end
  alias title event_title

  def event_dates
    "#{event_requests[0].start_date.strftime(date_format)} to #{event_requests[0].end_date.strftime(date_format)}"
  end

  def review_path
    Rails.application.routes.url_helpers.review_travel_request_url(request)
  end

  def show_path
    Rails.application.routes.url_helpers.travel_request_url(request)
  end

  def edit_path
    Rails.application.routes.url_helpers.edit_travel_request_url(request)
  end

  def review_details
    {
      "Trip ID" => request.id,
      "Type" => request_type.titleize,
      "Dates Away" => event_dates,
      "Destination" => event_requests[0].location,
      "Event" => event_title
    }
  end

  def next_supervisor
    return if creator.blank?
    supervisors = request.creator.supervisor_chain
    last_agent_index = supervisors.find_index(last_supervisor_to_approve) || -1
    supervisors[last_agent_index + 1]
  end

  def approve_details
    details = {}
    details["Travel Category"] = travel_category.humanize if travel_category.present?
    details.merge(review_details)
  end

  def travel_category
    return @request.travel_category if @request.travel_category.blank?
    @request.travel_category.humanize
  end

  # The form does not require the start date
  # Users have omitted this, which causes errors with the displays
  # For display purposes we will just use the event date if the start date is missing
  def start_date
    return request.start_date if request.start_date.present?
    event_requests.first&.start_date
  end

  # The form does not require the end date
  # Users have omitted this, which causes errors with the displays
  # For display purposes we will just use the event date if the end date is missing
  def end_date
    return request.end_date if request.end_date.present?
    event_requests.first&.end_date
  end

  private

    def list_event_attendees
      event_requests.map do |event_request|
        EventAttendees.list(recurring_event: event_request.recurring_event, event_start_date: start_date).uniq - [creator]
      end.flatten
    end

    def estimate_to_hash(estimate:)
      deco_estimate = EstimateDecorator.new(estimate)
      deco_estimate.data
    end
end
