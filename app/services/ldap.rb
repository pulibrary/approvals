# frozen_string_literal: true

class Ldap
  class << self
    def find_by_netid(net_id, ldap_connection: default_connection)
      filter = Net::LDAP::Filter.eq("uid", net_id)
      result = ldap_connection.search(filter:).first
      {
        netid: result[:uid].first,
        department: result[:ou].first,
        address: result[:puinterofficeaddress].first
      }
    end

    private

      def default_connection
        @default_connection ||= Net::LDAP.new host: "ldap.princeton.edu", base: "o=Princeton University,c=US", port: 636,
                                              encryption: {
                                                method: :simple_tls,
                                                tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
                                              }
      end
  end
end
