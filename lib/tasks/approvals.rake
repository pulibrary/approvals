namespace :approvals do
  desc "add fake users to give [:netid] someone to supervise"
  task :make_me_a_supervisor, [:netid, :number] => [:environment] do |_t, args|
    netid = args[:netid]
    number_of_people = args[:number].to_i || 5
    staff_profile = User.find_by(uid: netid).staff_profile
    RandomDirectReportsGenerator.create_reports(supervisor: staff_profile, number_of_people: number_of_people)
    puts "We made you a supervisor with #{number_of_people} direct reports"
  end

  desc "add a fake department and fake users to give [:netid] a department to head"
  task :make_me_a_department_head, [:netid, :number] => [:environment] do |_t, args|
    netid = args[:netid]
    number_of_people = args[:number].to_i || 5
    staff_profile = User.find_by(uid: netid).staff_profile
    RandomDirectReportsGenerator.create_populated_department(head: staff_profile, number_of_supervisors: number_of_people)
    puts "We made you a department head with #{number_of_people} direct reports, who have 5 reports each"
  end

  desc "add requests for every user in the system"
  task make_requests_for_everyone: :environment do
    StaffProfile.all.each do |staff_profile|
      next if staff_profile.supervisor.nil?
      1.upto(Random.rand(2...10)) do
        status = ["pending", "approved", "denied"].sample
        RandomRequestGenerator.generate_travel_request(creator: staff_profile, status: status)
      end
      1.upto(Random.rand(2...10)) do
        status = ["pending", "approved", "denied"].sample
        RandomRequestGenerator.generate_absence_request(creator: staff_profile, status: status)
      end
    end

    puts "#{TravelRequest.count} TravelRequests generated and #{AbsenceRequest.count} AbsenceRequests generated for #{StaffProfile.count} Staff"
  end
end
