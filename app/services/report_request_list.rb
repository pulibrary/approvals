# frozen_string_literal: true
class ReportRequestList < RequestList
  class << self
    def list_requests(current_staff_profile:, request_filters:, search_query:, order:, page: 1)
      record_scope = Request.joins(creator: :department)
                            .where(request_filters(request_filters: request_filters))
                            .where_contains_text(search_query: search_query)
                            .where(creator: list_supervised(list: [current_staff_profile], supervisor: current_staff_profile).map(&:id))
                            .order(request_order(order))
      paginate(record_scope: record_scope, page: page)
    end

    private

      def request_filters(request_filters:)
        department_filters(request_filters).merge(filters_hash(request_filters))
      end

      def department_filters(request_filters)
        return {} if request_filters.blank?
        department = request_filters.delete("department")
        if department.blank?
          {}
        else
          { "departments.number" => department }
        end
      end

      # sort_field can be any field, we use dates to start out with
      # sort_direction can be "asc" or "desc"
      # default is updated date, descending
      def request_order(sort_order)
        return { "updated_at" => "desc" } unless sort_order
        sort_field, _, sort_direction = sort_order.rpartition("_")
        { sort_field => sort_direction }
      end
  end
end
