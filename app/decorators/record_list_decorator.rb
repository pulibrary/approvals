# frozen_string_literal: true
#
#  ReportListDecorator decorates a request list with the ability to create filter urls, which can be used to filter the results.
#    This decorator supports the My Request page filter drop down menus in addition to supporting the display of the list of results.
#
class RecordListDecorator < RequestListDecorator
  def request_type_filters
    filters = {}
    filters["Absence"] = { url: absence_filter_url, children: absence_filter_urls } if Rails.configuration.show_absence_button
    filters
  end
end
