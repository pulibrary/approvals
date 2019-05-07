class RandomDirectReportsGenerator
  class << self
    def create_reports(supervisor:, number_of_people: 5)
      1.upto(number_of_people) do |_i|
        create_staff(supervisor)
      end
    end

    def create_populated_department(head:, number_of_supervisors: 3)
      department = Department.create!(head: head, name: "Department #{Random.rand(1...50)}")
      head.department = department
      1.upto(number_of_supervisors) do |_i|
        supervisor = create_staff(head)
        create_reports(supervisor: supervisor)
      end
    end

    private

      def create_staff(supervisor)
        user = nil
        begin
          index = Random.rand(1...50_000)
          user = User.create!(uid: "uid#{index}")
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        StaffProfile.create!(given_name: "given#{index}", surname: "surname#{index}",
                             department: supervisor.department, biweekly: false,
                             user: user, email: "#{user.uid}@princeton.edu",
                             supervisor: supervisor)
      end
  end
end
