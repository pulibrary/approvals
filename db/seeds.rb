# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
def create_profile(uid:, given_name:, surname:, department:, supervisor: nil, biweekly: false)
  user = User.create!(uid: uid)
  StaffProfile.create!(given_name: given_name, surname: surname,
                       department: department, biweekly: biweekly,
                       user: user, email: "#{user.uid}@princeton.edu",
                       supervisor: supervisor)
end

oul = Department.create!(name: "Library-Office of the University Librarian")
anne_profile = create_profile(uid: "ajarvis", department: oul,
                              given_name: "Anne", surname: "Jarvis")

itims = Department.create!(name: "Library Information Technology, Imaging and Metadata Services")
jon_profile = create_profile(uid: "jstroop", given_name: "Jon", surname: "Stroop",
                             department: itims, supervisor: anne_profile)
itims.head = jon_profile
itims.save!
kevin_profile = create_profile(uid: "kr2", given_name: "Kevin", surname: "Reiss",
                               department: itims, supervisor: jon_profile)
user_services = [{ uid: "cac9", given_name: "Carolyn", surname: "Cole" },
                 { uid: "aliauw", given_name: "Axa", surname: "Liauw" },
                 { uid: "shaune", given_name: "Shaun", surname: "Ellis" }]
user_services.each do |user|
  create_profile(**user, supervisor: kevin_profile, department: itims)
end

esme_profile = create_profile(uid: "kc16", given_name: "Esmé", surname: "Cowles",
                              department: itims, supervisor: jon_profile)
drds = [{ uid: "aheadley", given_name: "Anna", surname: "Headley" }]
drds.each do |user|
  create_profile(**user, supervisor: esme_profile, department: itims)
end

RecurringEvent.create(name: "Code4Lib", url: "https://code4lib.org/", 
                      description: "A volunteer-driven collective of hackers, designers, architects, curators, catalogers, artists and instigators from around the world, who largely work for and with libraries, archives and museums on technology “stuff.”")
RecurringEvent.create(name: "LDCX", url: "https://library.stanford.edu/projects/ldcx", 
                        description: "LDCX is an annual unconference that brings together leading technologists in the libraries, archives and museums (LAM) spaces, to work collaboratively on common needs.")
  
puts "Loaded #{StaffProfile.count} staff profiles in #{Department.count} departments"
puts "Loaded #{RecurringEvent.count} recurring events"

