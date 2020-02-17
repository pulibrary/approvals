# frozen_string_literal: true
class RequestList
  class << self
    def list_requests(creator:, request_filters:, search_query:, order:, page: 1)
      record_scope = Request
                     .where(request_filters(creator: creator, request_filters: request_filters))
                     .where_contains_text(search_query: search_query)
                     .order(my_request_order(order))
      paginate(record_scope: record_scope, page: page)
    end

    private

      def list_supervised(list:, supervisor:)
        supervised = StaffProfile.where(supervisor: supervisor)
        return list if supervised.empty?
        list |= supervised
        supervised.each { |staff| list = list_supervised(list: list, supervisor: staff) }
        list
      end

      def paginate(record_scope:, page:)
        offset = page_number(page) * per_page
        total_count = record_scope.count
        records = record_scope.limit(per_page).offset(offset)
        page = Kaminari.paginate_array(records, total_count: total_count).page(0)
        page.offset_value = offset
        page
      end

      def per_page
        Request.default_per_page
      end

      def page_number(page)
        page ||= 1
        page.to_i - 1
      end

      def request_filters(creator:, request_filters:)
        { creator: creator }.merge(filters_hash(request_filters))
      end

      # all filters from params
      def filters_hash(request_filters)
        return {} if request_filters.blank?

        filters = request_filters.to_hash
        map_request_type_filters(filters)
      end

      # These couple methods will likely be reused; consider making it into a class like
      # ParamsToFiltersConverter
      def map_request_type_filters(filters)
        request_type_filter = filters.delete("request_type")
        filters.merge!(request_type_value(request_type_filter)) if request_type_filter.present?
        filters
      end

      # translate a param into a property value
      def request_type_value(param_value)
        if param_value == "absence"
          { request_type: "AbsenceRequest" }
        elsif param_value == "travel"
          { request_type: "TravelRequest" }
        elsif Request.travel_categories.values.include?(param_value)
          { request_type: "TravelRequest", travel_category: param_value }
        else
          { request_type: "AbsenceRequest", absence_type: param_value }
        end
      end

      # sort_field can be any field, we use dates to start out with
      # sort_direction can be "asc" or "desc"
      # default is updated date, descending
      def my_request_order(sort_order)
        return { "updated_at" => "desc" } unless sort_order
        sort_field, _, sort_direction = sort_order.rpartition("_")
        { sort_field => sort_direction }
      end
  end
end
