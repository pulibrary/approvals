# This migration will cause loss of data in the request table due to
#  the fact that columns are being removed
class ConvertRequestStringsToEnums < ActiveRecord::Migration[5.2]
  def up
    remove_column :requests, :participation, :string
    remove_column :requests, :travel_category, :string
    remove_column :requests, :absence_type, :string
    execute <<-SQL
      CREATE TYPE request_participation_category AS ENUM ('presenter', 'member', 'committee_chair', 'committee_member', 'other', 'site_visit', 'training', 'vendor_visit', 'donor_visit', 'participant');
      CREATE TYPE request_travel_category AS ENUM ('business', 'professional_development', 'discretionary');
      CREATE TYPE request_absence_type AS ENUM ('consulting', 'vacation_monthly', 'personal', 'sick', 'jury_duty', 'death_in_family', 'research_days', 'work_from_home');
    SQL
    add_column :requests, :participation, :request_participation_category
    add_column :requests, :travel_category, :request_travel_category
    add_column :requests, :absence_type, :request_absence_type
  end

  def down
    remove_column :requests, :participation, :request_participation_category
    remove_column :requests, :travel_category, :request_travel_category
    remove_column :requests, :absence_type, :request_absence_type

    execute <<-SQL
      DROP TYPE request_participation_category;
      DROP TYPE request_travel_category;
      DROP TYPE request_absence_type;
    SQL

    add_column :requests, :participation, :string
    add_column :requests, :travel_category, :string
    add_column :requests, :absence_type, :string
  end
end
