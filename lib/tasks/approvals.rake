# frozen_string_literal: true
namespace :approvals do
  desc "add fake users to give [:netid] someone to supervise"
  task :make_me_a_supervisor, [:netid, :number] => [:environment] do |_t, args|
    netid = args[:netid]
    number_of_people = args[:number].to_i || 5
    staff_profile = StaffProfile.find_by(uid: netid)
    RandomDirectReportsGenerator.create_reports(supervisor: staff_profile, number_of_people: number_of_people)
    puts "We made you a supervisor with #{number_of_people} direct reports"
    puts "You now manage #{StaffProfile.where(supervisor: staff_profile).map(&:uid).join(', ')}"
    puts "We are now making requests for all your direct reports"
    StaffProfile.where(supervisor: staff_profile).each { |sp| make_requests(staff_profile: sp) }
  end

  desc "add a fake department and fake users to give [:netid] a department to head"
  task :make_me_a_department_head, [:netid, :number] => [:environment] do |_t, args|
    netid = args[:netid]
    number_of_people = args[:number].to_i || 5
    staff_profile = User.find_by(uid: netid).staff_profile
    RandomDirectReportsGenerator.create_populated_department(head: staff_profile, number_of_supervisors: number_of_people)
    puts "We made you a department head with #{number_of_people} direct reports, who have #{number_of_people} reports each"
  end

  desc "add requests for [:netid] user"
  task :make_requests_for_user, [:netid] => [:environment] do |_t, args|
    netid = args[:netid]
    staff_profile = StaffProfile.find_by(uid: netid)
    make_requests(staff_profile: staff_profile)
    puts "We made #{staff_profile} #{TravelRequest.where(creator: staff_profile).count} Travel Requests and #{AbsenceRequest.where(creator: staff_profile).count} Absence Requests"
  end

  desc "add requests for every user in the system"
  task make_requests_for_everyone: :environment do
    StaffProfile.all.each do |staff_profile|
      next if staff_profile.supervisor.nil?
      make_requests(staff_profile: staff_profile)
    end

    puts "#{TravelRequest.count} TravelRequests generated and #{AbsenceRequest.count} AbsenceRequests generated for #{StaffProfile.count} Staff"
  end

  desc "process the staff list"
  task process_staff_report: :environment do
    file = File.open(Rails.application.config.staff_report_location, encoding: "UTF-16")
    report = file.read
    StaffReportProcessor.process(data: report)
    Department.all.each do |department|
      puts department.name
      puts "    Head: #{department.head}"
      StaffProfile.where(department: department).order(:surname).each do |profile|
        puts "      #{profile}"
      end
    end
  end

  desc "process the balance report"
  task process_balance_report: :environment do
    file = File.open(Rails.application.config.balance_report_location, encoding: "UTF-16")
    report = file.read
    errors = BalanceReportProcessor.process(data: report)
    puts "Completed processing the balance report."
    abort("There were unknown entries: #{errors[:unknown].join(', ')}") if errors[:unknown].present?
  end

  desc "process the balance report"
  task process_reports: :environment do
    Rake::Task["approvals:process_staff_report"].invoke
    Rake::Task["approvals:process_balance_report"].invoke
  end

  desc "Load locations"
  task load_locations: :environment do
    LocationLoader.load
  end

  desc "Make a delegate record so delegate_uid can act on behalf of delegator_uid"
  task :make_delegate, [:delegate_uid, :delegator_uid] => [:environment] do |_t, args|
    delegate_uid = args[:delegate_uid]
    delegator_uid = args[:delegator_uid]
    if delegate_uid.blank? || delegator_uid.blank?
      message = "you must specify both a delegate_uid and a delegator_uid!!! \n" \
                "rake approvals:make_delegate[ab1,cd2]"
      abort message
    end
    delegate = StaffProfile.find_by(uid: delegate_uid)
    abort "Invalid delegate uid (netid) #{delegate_uid}" if delegate.blank?

    delegator = StaffProfile.find_by(uid: delegator_uid)
    abort "Invalid delegator uid (netid) #{delegator_uid}" if delegator.blank?

    begin
      Delegate.create!(delegate: delegate, delegator: delegator)
    rescue ActiveRecord::RecordInvalid => error
      abort error.message
    end

    puts "created #{delegate} can now act on behalf of #{delegator}"
  end

  desc "Make sure this user is no longer anybody's delegate"
  task :stop_being_a_delegate, [:delegate_uid] => [:environment] do |_t, args|
    delegate_uid = args[:delegate_uid]
    delegate = StaffProfile.find_by(uid: delegate_uid)
    abort "Invalid delegate uid (netid) #{delegate_uid}" if delegate.blank?

    results = Delegate.where(delegate_id: delegate.id).destroy_all
    puts "#{delegate_uid} was previously a delegate for #{results.count} other users \n" \
         "#{delegate_uid} is no longer serving as a delegate for anyone."
  end

  desc "Remove a departing admin assistant from workflows"
  task :remove_admin_assistant, [:uid] => :environment do |_t, args|
    Rake::Task["approvals:stop_being_a_delegate"].invoke(args[:uid])
    Rake::Task["approvals:process_staff_report"].invoke
  end

  namespace :reports do
    desc "Create a CSV report of approved trips within a date range"
    task :approved_trips, [:start_date, :end_date, :file_path] => [:environment] do |_t, args|
      file_path = args[:file_path] || "./tmp/approved_request_report.csv"
      run_report(args: args, file_path: file_path, approved_only: true)
    end
    desc "Create a CSV report of all trips, regardless of status, within a date range"
    task :all_trips, [:start_date, :end_date, :file_path] => [:environment] do |_t, args|
      file_path = args[:file_path] || "./tmp/all_request_report.csv"
      run_report(args: args, file_path: file_path)
    end
  end

  def make_requests(staff_profile:)
    1.upto(Random.rand(5...20)) do
      status = ["pending", "approved", "denied", "changes_requested", "canceled"].sample
      RandomRequestGenerator.generate_travel_request(creator: staff_profile, status: status)
    end
    1.upto(Random.rand(6...24)) do
      status = ["pending", "approved", "denied", "canceled", "recorded"].sample
      RandomRequestGenerator.generate_absence_request(creator: staff_profile, status: status)
    end
  end
end

def run_report(args:, file_path:, approved_only: false)
  validate_report_args(args)
  RequestReport.new(start_date: args[:start_date],
                    end_date: args[:end_date],
                    file_path: file_path,
                    approved_only: approved_only).csv
  puts "Report successfully generated and saved to #{file_path}"
end

def validate_report_args(args)
  abort "Please supply a start date and end date" unless args[:start_date] && args[:end_date]
  begin
    Date.strptime(args[:start_date], "%m/%d/%Y") && Date.strptime(args[:end_date], "%m/%d/%Y")
  rescue Date::Error
    abort "Invalid date -- please confirm that you are using MM/DD/YYYY format"
  end
end
