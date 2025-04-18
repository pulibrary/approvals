# frozen_string_literal: true

#
#  ReportListDecorator decorates a request list with the ability to create filter urls, which can be used to filter the results.
#    This decorator supports the My Request page filter drop down menus in addition to supporting the display of the list of results.
#
class ReportListDecorator < RequestListDecorator
  def data_table_heading
    "#{data_table_heading_filters} sorted by #{sort_options_table[params_manager.current_sort]}".titleize.gsub("   ",
                                                                                                               " ")
  end

  # only used for report
  def current_department_filter_label
    filters = params_manager.filter_params
    if filters[:department].present?
      "Department: #{clean_department_name(filters[:department])}"
    else
      "Department"
    end
  end

  def current_event_format_filter_label
    filters = params_manager.filter_params
    if filters[:virtual_event].present?
      return "Event format: Virtual" if filters[:virtual_event] == "true"
      return "Event format: In-person" if filters[:virtual_event] == "false"
    end
    "Event format"
  end

  def filter_label(key, value)
    if key == :department
      "#{key.to_s.humanize}: #{clean_department_name(value)}"
    elsif key == :supervisor
      profile = StaffProfile.find(value)
      "#{key.to_s.humanize}: #{profile.full_name}"
    elsif key == :virtual_event
      current_event_format_filter_label
    else
      super
    end
  end

  def clean_department_name(number)
    @department_mapping ||= { "41004" => "Finance & Administration",
                              "41006" => "Information Technology Imaging and Metdata Services",
                              "41014" => "Special Collections",
                              "41032" => "Scholarly Collections & Research Services",
                              "41000" => "Main",
                              "10001" => "Research Collections & Preservation Consortium" }
    @department_mapping[number] || Department.find_by(number:).name
  end

  # @returns [Hash] Labels and urls for the department dropdown menu
  def department_filter_urls
    Department.all.map do |department|
      [clean_department_name(department.number),
       params_manager.url_with_filter(field: :department, new_option: department.number)]
    end.to_h
  end

  # @returns [Hash] Labels and urls for the event format dropdown menu
  def event_format_filter_urls
    {
      "In-person" => params_manager.url_with_filter(field: :virtual_event, new_option: false),
      "Virtual" => params_manager.url_with_filter(field: :virtual_event, new_option: true)
    }
  end

  def report_json
    request_list.map do |request|
      {
        id: request.id,
        request_type: { value: title(request), link: Rails.application.routes.url_helpers.url_for(request) },
        start_date: request.formatted_full_start_date,
        end_date: request.formatted_full_end_date,
        status: request.latest_status,
        staff: request.full_name,
        department: request.department.name,
        event_format: request.event_format,
        approval_date: approval_date(request),
        total: total(request)
      }
    end.to_json
  end

  def current_supervisor_filter_label
    filters = params_manager.filter_params
    supervisor = StaffProfile.find_by_id(filters[:supervisor])
    return "Supervisor" if supervisor.blank?

    "Supervisor: #{supervisor.full_name}"
  end

  def supervisor_filter_urls(current_staff_profile:)
    supervised = current_staff_profile.list_supervised(list: [])
    supervised.select(&:supervisor?).map do |staff|
      [staff.full_name, params_manager.url_with_filter(field: :supervisor, new_option: staff.id)]
    end.to_h.sort
  end

  private

    def data_table_heading_filters
      filters = params_manager.filter_params
      return "All requests" if filters.blank?

      heading = "#{filters[:status]} #{filters[:request_type]} requests"
      heading += " in #{clean_department_name(filters[:department])}" if filters[:department]
      heading
    end

    def title(request)
      if request.travel?
        request.title
      else
        "#{request.title} (#{request.hours_requested} hours)"
      end
    end

    def approval_date(request)
      if request.status == "approved"
        request.updated_at.strftime("%B %-d, %Y")
      else
        ""
      end
    end

    def total(request)
      if request.is_a?(TravelRequestDecorator)
        total = 0.00
        request.estimates.each do |est|
          total += est.amount * est.recurrence
        end
        format("%.2f", total)
      else
        "0.00"
      end
    end
end
