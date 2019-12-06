# frozen_string_literal: true
class ApprovalRequestList < RequestList
  class << self
    def list_requests(approver:, request_filters:, search_query:, order:)
      records = Request
                .where(request_filters(request_filters: request_filters))
                .where_contains_text(search_query: search_query)
                .where(creator: list_supervised(list: [], supervisor: approver).map(&:id))
                .order(my_request_order(order))

      filter_records_by_approver(records: records, approver: approver)
    end

    private

      def list_supervised(list:, supervisor:)
        supervised = StaffProfile.where(supervisor: supervisor)
        return list if supervised.empty?
        list |= supervised
        supervised.each { |staff| list = list_supervised(list: list, supervisor: staff) }
        list
      end

      def request_filters(request_filters:)
        { status: "pending" }.merge(filters_hash(request_filters))
      end

      def filter_records_by_approver(records:, approver:)
        records.select do |request|
          only_next_supervisor(request: request, approver: approver) && !already_approved?(request: request, approver: approver)
        end
      end

      def only_next_supervisor(request:, approver:)
        supervisors = supervisor_chain(agent: request.creator)
        approver_index = supervisors.index(approver)
        previous_supervisors = supervisors.slice(0, approver_index)
        previous_supervisors.all? { |supervisor| already_approved?(request: request, approver: supervisor) }
      end

      def already_approved?(request:, approver:)
        StateChange.where(request_id: request.id, agent_id: approver.id).count.positive?
      end

      def supervisor_chain(agent:, list: [])
        return list if agent.supervisor.blank?

        list << agent.supervisor
        supervisor_chain(agent: agent.supervisor, list: list)
      end

      # default is start date, ascending
      def my_request_order(sort_order)
        return { "start_date" => "asc" } unless sort_order
        sort_field, _, sort_direction = sort_order.rpartition("_")
        { sort_field => sort_direction }
      end
  end
end
