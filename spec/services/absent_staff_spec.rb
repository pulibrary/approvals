# frozen_string_literal: true
require "rails_helper"

RSpec.describe AbsentStaff, type: :model do
  let(:supervisor) { FactoryBot.create :staff_profile, given_name: "Goose" }
  let(:jack) { FactoryBot.create :staff_profile, given_name: "Jack", supervisor: supervisor }
  let(:jill) { FactoryBot.create :staff_profile, given_name: "Jill", supervisor: supervisor }
  let(:mary) { FactoryBot.create :staff_profile, given_name: "Mary", supervisor: jill }
  let(:peter) { FactoryBot.create :staff_profile, given_name: "Peter", supervisor: supervisor }
  let(:piper) { FactoryBot.create :staff_profile, given_name: "Piper", supervisor: peter }
  let(:mary_sick_2020) do
    start_date = Time.zone.now + 1.year
    end_date = start_date + 2.days
    FactoryBot.create :absence_request, creator: mary, start_date: start_date, end_date: end_date
  end
  let(:peter_sick_2020) do
    start_date = Time.zone.now + 1.year
    end_date = start_date + 2.days
    FactoryBot.create :absence_request, creator: peter, start_date: start_date, end_date: end_date
  end
  let(:mary_sick_2019) do
    start_date = Time.zone.now
    end_date = start_date + 2.days
    FactoryBot.create :absence_request, creator: mary, start_date: start_date, end_date: end_date
  end
  let(:jack_vacation_2019) do
    start_date = Time.zone.now + 2.days
    end_date = start_date + 4.days
    FactoryBot.create :absence_request, creator: jack, start_date: start_date, end_date: end_date
  end
  let(:jill_vacation_2019) do
    start_date = Time.zone.now - 3.days
    end_date = start_date + 4.days
    FactoryBot.create :absence_request, creator: jill, start_date: start_date, end_date: end_date
  end
  let(:piper_vacation_2019) do
    start_date = Time.zone.now - 3.days
    end_date = start_date + 4.days
    FactoryBot.create :absence_request, creator: piper, start_date: start_date, end_date: end_date
  end

  before do
    mary_sick_2019
    jack_vacation_2019
    jill_vacation_2019
    piper_vacation_2019
    mary_sick_2020
    peter_sick_2020
  end

  describe "#list" do
    it "returns absent staff" do
      expect(AbsentStaff.list(start_date: Time.zone.now, end_date: Time.zone.now + 2.days, supervisor: supervisor)).to contain_exactly(mary, jack, jill, piper)
    end

    it "returns absent staff when window is inside the staff absence" do
      expect(AbsentStaff.list(start_date: Time.zone.now - 2.days, end_date: Time.zone.now - 1.day, supervisor: supervisor)).to contain_exactly(jill, piper)
    end

    it "returns absent staff when window is around end date of the absence" do
      expect(AbsentStaff.list(start_date: Time.zone.now + 2.days, end_date: Time.zone.now + 5.days, supervisor: supervisor)).to contain_exactly(mary, jack)
    end

    it "returns no one when the supervisor is other" do
      expect(AbsentStaff.list(start_date: Time.zone.now + 2.days, end_date: Time.zone.now + 5.days, supervisor: piper)).to be_empty
    end
  end
end
