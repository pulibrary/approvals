# frozen_string_literal: true

class RandomDirectReportsGenerator
  class << self
    def create_reports(supervisor:, number_of_people: 5)
      1.upto(number_of_people) do |_i|
        create_staff(supervisor)
      end
    end

    def create_populated_department(head:, number_of_supervisors: 3)
      department = Department.create!(head:,
                                      name: "Department of #{Faker::Hacker.adjective} #{Faker::Hacker.noun}")
      head.department = department
      1.upto(number_of_supervisors) do |_i|
        supervisor = create_staff(head)
        create_reports(supervisor:)
      end
    end

    private

      def create_staff(supervisor)
        user = nil
        begin
          index = Random.rand(1...50_000)
          user = User.create!(uid: "uid#{index}")
          location = Location.create!(building: Faker::Address.community)
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        StaffProfile.create!(given_name: Faker::Name.first_name, surname: Faker::Name.last_name,
                             department: supervisor.department, biweekly: false,
                             user:, email: "#{user.uid}@princeton.edu", location:,
                             supervisor:, vacation_balance: Random.rand(1...50),
                             sick_balance: Random.rand(1...50), personal_balance: Random.rand(1...50))
      end
  end
end
