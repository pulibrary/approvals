# frozen_string_literal: true
#
#  ReportListDecorator decorates a request list with the ability to create filter urls, which can be used to filter the results.
#    This decorator supports the My Request page filter drop down menus in addition to supporting the display of the list of results.
#
class ReportListDecorator < RequestListDecorator
  def data_table_heading
    "#{data_table_heading_filters} sorted by #{sort_options_table[params_manager.current_sort]}".titleize.gsub("   ", " ")
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

  def filter_label(key, value)
    if key == :department
      "#{key.to_s.humanize}: #{clean_department_name(value)}"
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
    @department_mapping[number] || Department.find_by(number: number).name
  end

  # @returns [Hash] Labels and urls for the department dropdown menu
  def department_filter_urls
    Department.all.map do |department|
      [clean_department_name(department.number), params_manager.url_with_filter(field: :department, new_option: department.number)]
    end.to_h
  end

  def report_json
    request_list.map do |request|
      {
        'id': request.id,
        'request_type':  request.title,
        'start_date': request.formatted_full_start_date,
        'end_date': request.formatted_full_end_date,
        'status':  request.latest_status,
        'staff':  request.full_name,
        'department': request.department.name
      }
    end.to_json
  end

  private

    def data_table_heading_filters
      filters = params_manager.filter_params
      return "All requests" if filters.blank?
      heading = "#{filters[:status]} #{filters[:request_type]} requests"
      heading += " in #{clean_department_name(filters[:department])}" if filters[:department]
      heading
    end
end
