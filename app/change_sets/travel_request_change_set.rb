# frozen_string_literal: true

class TravelRequestChangeSet < RequestChangeSet
  property :travel_category
  property :purpose
  property :participation
  property :virtual_event

  # to allow for error messages to be attached to the form fields
  property :travel_dates
  property :event_dates

  collection :event_requests, form: EventRequestChangeSet, populator: EventRequestChangeSet::EventRequestPopulator,
                              prepopulator: EventRequestChangeSet::EventRequestPrepopulator
  collection :estimates, form: EstimateChangeSet, populator: EstimateChangeSet::EstimatePopulator

  validates :travel_category, inclusion: { in: TravelCategoryList.categories, allow_blank: true }
  validates :event_requests, presence: true
  validates :participation, inclusion: { in: Request.participations.keys }

  delegate :travel_category_icon, :current_note,
           :estimate_fields_json, :estimates_json,
           :event_format, :event_format_color,
           to: :decorated_model

  attr_reader :current_staff_profile

  def existing_notes
    sorted_notes = notes.map(&:model).select { |n| n.creator.present? }.sort_by(&:created_at)
    sorted_notes.map do |item|
      {
        title: "#{item.creator.full_name} on #{item.created_at.strftime(Rails.configuration.short_date_format)}",
        content: item.content,
        icon: "note"
      }
    end
  end

  def estimate_cost_options
    EstimateDecorator.cost_options_json
  end

  def travel_category_options
    # turn key, value into label, key
    strings = TravelCategoryList.current_categories.map do |category|
      "{label: '#{category.humanize}', value: '#{category}'}"
    end
    "[#{strings.join(',')}]"
  end

  def event_format_options
    "[{label: 'In-person', value: false},
      {label: 'Virtual', value: true}]"
  end

  def participation_options
    # turn key, value into label, key
    participation_options = model.class.participations.sort_by { |_key, value| value }
    strings = participation_options.map do |key, value|
      "{label: '#{value.humanize}', value: '#{key}'}"
    end
    "[#{strings.join(',')}]"
  end

  def estimates_json_form
    estimates.map do |estimate|
      {
        id: estimate.id,
        cost_type: estimate.cost_type,
        amount: estimate.amount,
        recurrence: estimate.recurrence,
        description: estimate.description,
        other_id: SecureRandom.uuid
      }
    end.to_json
  end

  def travel_dates_js
    date_range_js(start_date, end_date)
  end

  def event_dates_js
    date_range_js(event_requests[0].start_date, event_requests[0].end_date)
  end

  def event_name
    return "" if event_requests.empty? || event_requests[0].recurring_event.blank?

    event_requests[0].recurring_event.name
  end

  def self.recurring_event_list
    if @previous_count != RecurringEvent.count
      @values = RecurringEvent.all.map do |event|
        { id: event.id, label: event.name }
      end
      @previous_count = RecurringEvent.count
    end

    @values.to_json
  end

  def recurring_event_list
    if @previous_count != RecurringEvent.count
      @values = RecurringEvent.all.map do |event|
        { id: event.id, label: event.name }
      end
      @previous_count = RecurringEvent.count
    end

    @values.to_json
  end

  def supervisor
    if model.creator
      model.creator.supervisor
    else
      current_staff_profile.supervisor
    end
  end

  def creator
    model.creator || current_staff_profile
  end

  private

    def date_range_js(start_date, end_date)
      "{ start: new Date('#{format_date_js(start_date)}'), end: new Date('#{format_date_js(end_date)}') }"
    end

    def format_date_js(date)
      ldate = date || Time.zone.today
      ldate.strftime("%m/%d/%Y")
    end

    def decorated_model
      @decorated_model ||= TravelRequestDecorator.new(model)
    end
end
