# frozen_string_literal: true
require "rails_helper"

RSpec.describe Ldap, type: :model do
  describe "#find_by_netid" do
    # this test can not be run on circle (tagged :no_ci to not run on circle ci)
    it "returns json ldap data about the user when connected to the actual ldap (you must be on campus or VPN for this to work)", :no_ci do
      expect(described_class.find_by_netid("cac9")).to eq(address: "Firestone Library$Library Information Technology",
                                                          department: "Library - Deputy University Library",
                                                          netid: "cac9")
    end

    # This test is dangerous on it's own because the results from LDAP could change without us knowing.
    # That said circle ci can not connect to ldap, so this test is for circle.
    # The test above talks directly to LDAP so if things change we should see a failure when we run it locally.
    context "I stub out the connection" do
      let(:entry) { instance_double(Net::LDAP::Entry) }
      let(:connection) { instance_double(Net::LDAP, search: [entry]) }

      it "returns json about the user" do
        allow(entry).to receive(:[]).with(:uid).and_return(["cac9"])
        allow(entry).to receive(:[]).with(:ou).and_return(["Library - Deputy University Library"])
        allow(entry).to receive(:[]).with(:puinterofficeaddress).and_return(["Firestone Library$Library Information Technology"])

        expect(described_class.find_by_netid("cac9", ldap_connection: connection)).to eq(address: "Firestone Library$Library Information Technology",
                                                                                         department: "Library - Deputy University Library",
                                                                                         netid: "cac9")
      end
    end
  end
end
