# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# lodaing locations from default configuration
LocationLoader.load

file = File.open(Rails.application.config.staff_report_location, encoding: "UTF-16")
report = file.read
StaffReportProcessor.process(data: report)

# process the seeds a second time to put in the AAs since they should now exist
LocationLoader.load

RecurringEvent.create(name: "Code4Lib", url: "https://code4lib.org/", 
  description: "A volunteer-driven collective of hackers, designers, architects, curators, catalogers, artists and instigators from around the world, who largely work for and with libraries, archives and museums on technology “stuff.”")
RecurringEvent.create(name: "LDCX", url: "https://library.stanford.edu/projects/ldcx", 
    description: "LDCX is an annual unconference that brings together leading technologists in the libraries, archives and museums (LAM) spaces, to work collaboratively on common needs.")
