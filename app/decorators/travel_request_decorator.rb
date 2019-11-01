# frozen_string_literal: true
class TravelRequestDecorator < RequestDecorator
  delegate :participation, :purpose, :travel_category,
           :event_requests, :estimates, :status, to: :request
  delegate :full_name, to: :creator
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
      amount: "Total",
      total: format("%.2f", grand_total)
    )

    estimate_list.to_json
  end

  def estimate_fields_json
    "[{ 'name': 'cost_type', 'display_name': 'Expense Type' },
      { 'name': 'note', 'display_name': 'Note' },
      { 'name': 'recurrence', 'display_name': 'Occurrences', 'datatype': 'number' },
      { 'name': 'amount', 'display_name': 'Cost per Occurrence', 'datatype': 'number' },
      { 'name': 'total', 'display_name': 'Total', 'datatype': 'number' } ]"
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
    "#{request.event_title} (#{event_requests[0].start_date.strftime(date_format)} to #{event_requests[0].end_date.strftime(date_format)})"
  end

  private

    def list_event_attendees
      attendees = []
      event_requests.each do |event_request|
        attendees.concat EventAttendees.list(recurring_event: event_request.recurring_event, event_start_date: start_date).uniq - [creator]
      end
      attendees
    end

    def estimate_to_hash(estimate:)
      { cost_type: estimate.cost_type,
        note: estimate.description || "",
        recurrence: estimate.recurrence,
        amount: format("%.2f", estimate.amount),
        total: format("%.2f", estimate.recurrence * estimate.amount) }
    end
end
