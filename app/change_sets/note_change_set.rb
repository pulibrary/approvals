class NoteChangeSet < Reform::Form
  property :creator_id
  property :content

  validates :creator_id, :content, presence: true

  validate :creator_id do
    creator = StaffProfile.find_by(id: creator_id)
    errors.add(:creator_id, "Creator must be a StaffProfile") if creator.blank?
  end

  NotePopulator = lambda { |collection:, **|
    collection.append(Note.new)
  }
end
