# This migration will cause loss of data in the request table due to
#  the fact that columns are being removed
class AddParticipationCategoryValues < ActiveRecord::Migration[5.2]
  def up
    remove_column :requests, :participation, :string
    execute <<-SQL
      DROP TYPE request_participation_category;
      CREATE TYPE request_participation_category AS ENUM ('presenter', 'member', 'committee_chair', 'committee_member', 'other', 'site_visit', 'training', 'vendor_visit', 'donor_visit', 'participant');
    SQL
    add_column :requests, :participation, :request_participation_category
  end
end