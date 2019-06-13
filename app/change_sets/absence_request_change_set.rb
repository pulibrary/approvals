# frozen_string_literal: true
class AbsenceRequestChangeSet < Reform::Form
  property :creator_id
  property :absence_type
  property :start_date
  property :end_date
  collection :notes, form: NoteChangeSet, populator: NoteChangeSet::NotePopulator

  validates :absence_type, inclusion: { in: Request.absence_types.keys }
  validates :creator_id, presence: true

  def absence_type_options
    # turn key, value into label, key
    strings = model.class.absence_types.map do |key, value|
      "{label: '#{value.humanize}', value: '#{key}'}"
    end
    "[#{strings.join(',')}]"
  end
end
