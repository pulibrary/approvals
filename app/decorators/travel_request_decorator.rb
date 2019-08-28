# frozen_string_literal: true
class TravelRequestDecorator < RequestDecorator
  delegate :participation, :purpose, :travel_category, :event_title, :creator,
           :event_requests, :notes, :estimates, :status, to: :travel_request
  attr_reader :travel_request

  def initialize(travel_request)
    super(travel_request)
    @travel_request = travel_request
  end

  def estimates_json
    estimate_list = []
    grand_total = 0
    estimates.each do |estimate|
      estimate_list.append({
        cost_type: estimate.cost_type,
        note: '',
        recurrence: estimate.recurrence,
        amount: sprintf('%.2f', estimate.amount),
        total: sprintf('%.2f', estimate.recurrence * estimate.amount)
      })
      grand_total = grand_total + estimate.recurrence * estimate.amount
    end

    estimate_list.append({
      cost_type: '',
      note: '',
      recurrence: '',
      amount: 'Total:',
      total: sprintf('%.2f', grand_total)
      })

    estimate_list.to_json
  end

  def estimate_fields_json
    "[{ 'name': 'cost_type', 'display_name': 'Expense Type' },
      { 'name': 'note', 'display_name': 'Note' },
      { 'name': 'recurrence', 'display_name': 'Occurrences', 'datatype': 'number' },
      { 'name': 'amount', 'display_name': 'Cost per Occurrence', 'datetype': 'number' },
      { 'name': 'total', 'display_name': 'Total', 'datetype': 'number' } ]"
  end

  def travel_category_icon
    "lux-icon-globe"
  end

  def attendance
    case status
    when 'denied'
        " will not attend "
      when 'approved'
        " will attend "
      else
        " wants to attend "
      end
  end
end
