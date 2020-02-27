# frozen_string_literal: true
class ReportRequestList < RequestList
  class << self
    def list_requests(current_staff_profile:, request_filters:, search_query:, order:)
      request_filters ||= {}
      supervisor_filter = request_filters.delete("supervisor")
      supervisor_filter = StaffProfile.find_by_id(supervisor_filter) if supervisor_filter.is_a? String
      supervisor = supervisor(current_staff_profile: current_staff_profile, supervisor_filter: supervisor_filter)
      Request.joins(creator: :department)
             .where(request_filters(request_filters: request_filters))
             .where_contains_text(search_query: search_query)
             .where(creator: list_supervised(list: [supervisor], supervisor: supervisor).map(&:id))
             .order(request_order(order))
    end

    private

      def supervisor(current_staff_profile:, supervisor_filter:)
        return current_staff_profile if supervisor_filter.blank?
        if supervises(supervisor_profile: current_staff_profile, staff_profile: supervisor_filter)
          supervisor_filter
        else
          current_staff_profile
        end
      end

      def supervises(supervisor_profile:, staff_profile:)
        return true if staff_profile.supervisor == supervisor_profile
        return false if staff_profile.supervisor.blank?
        supervises(supervisor_profile: supervisor_profile, staff_profile: staff_profile.supervisor)
      end

      def request_filters(request_filters:)
        department_filters(request_filters).merge(employee_type_filters(request_filters)).merge(filters_hash(request_filters))
      end

      def employee_type_filters(request_filters)
        filter = request_filters.delete("employee_type")
        if filter.blank?
          {}
        else
          { "staff_profiles.biweekly" => filter == "biweekly" }
        end
      end

      def department_filters(request_filters)
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
