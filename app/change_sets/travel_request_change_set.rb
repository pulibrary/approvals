# frozen_string_literal: true
class TravelRequestChangeSet < Reform::Form
  property :creator_id
  property :travel_category
  property :start_date
  property :end_date
  property :purpose
  property :participation

  collection :notes, form: NoteChangeSet, populator: NoteChangeSet::NotePopulator
  collection :event_requests, form: EventRequestChangeSet, populator: EventRequestChangeSet::EventRequestPopulator, prepopulator: EventRequestChangeSet::EventRequestPrepopulator
  collection :estimates, form: EstimateChangeSet, populator: EstimateChangeSet::EstimatePopulator

  validates :travel_category, inclusion: { in: Request.travel_categories.keys, allow_blank: true }
  validates :creator_id, presence: true
  validates :event_requests, presence: true

  def estimate_cost_options
    # turn key, value into label, key
    strings = Estimate.cost_types.map do |key, value|
      "{label: '#{value.humanize}', value: '#{key}'}"
    end
    "[#{strings.join(',')}]"
  end

  def travel_category_options
    # turn key, value into label, key
    strings = model.class.travel_categories.map do |key, value|
      "{label: '#{value.humanize}', value: '#{key}'}"
    end
    "[#{strings.join(',')}]"
  end

  def participation_options
    # turn key, value into label, key
    strings = model.class.participations.map do |key, value|
      "{label: '#{value.humanize}', value: '#{key}'}"
    end
    "[#{strings.join(',')}]"
  end

  def estimates_json
    estimates.map do |estimate|
      {
        id: estimate.id,
        cost_type: estimate.cost_type,
        amount: estimate.amount,
        recurrence: estimate.recurrence,
        description: estimate.description
      }
    end.to_json
  end

  def travel_dates_js
    date_range_js(start_date, end_date)
  end

  def event_dates_js
    date_range_js(event_requests[0].start_date, event_requests[0].end_date)
  end

  def event_id
    return "" if event_requests.empty? || event_requests[0].recurring_event.blank?

    event_requests[0].recurring_event.id
  end

  def recurring_event_list
    @values ||= RecurringEvent.all.limit(50).map do |event|
      "{ value: '#{event.id}', label: '#{event.name}' }"
    end.join(",")
    "[#{@values}]"

    # "[
    #             { value: 'Code4Lib', label: 'Code4Lib Annual Conference' },
    #             { value: 'ALA', label: 'American Library Association Annual' },
    #             { value: 'DLF', label: 'Digital Library Federation' },
    #             { value: 'SAA', label: 'Society of American Archivists Annual Conference' },
    #             { value: 'Access', label: 'Access Annual Conference' }
    # ]"
  end

  private

    def date_range_js(start_date, end_date)
      "{ start: new Date('#{format_date_js(start_date)}'), end: new Date('#{format_date_js(end_date)}') }"
    end

    def format_date_js(date)
      ldate = date || Time.zone.today
      ldate.strftime("%m/%d/%Y")
    end
end
