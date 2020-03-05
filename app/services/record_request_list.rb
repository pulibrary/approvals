# frozen_string_literal: true
class RecordRequestList < RequestList
  class << self
    def list_requests(current_staff_profile:, request_filters:, search_query:, order:, page: 1)
      request_filters ||= {}
      record_scope = AbsenceRequest.joins(creator: :department)
                                   .where(request_filters(creator: current_staff_profile, request_filters: request_filters))
                                   .where(status: :approved)
                                   .where_contains_text(search_query: search_query)
                                   .where_filtered_by_date(start_date: start_date_filter, end_date: end_date_filter)
                                   .order(request_order(order))
      paginate(record_scope: record_scope, page: page)
    end

    private

      # sort_field can be any field, we use dates to start out with
      # sort_direction can be "asc" or "desc"
      # default is updated date, descending
      def request_order(sort_order)
        return { "start_date" => "desc" } unless sort_order
        sort_field, _, sort_direction = sort_order.rpartition("_")
        { sort_field => sort_direction }
      end
  end
end
