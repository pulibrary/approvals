# a single table inheritance class
#  - attributes are defined on Request
#  - behavior can be defined here
class AbsenceRequest < Request
  def to_s
    "#{creator} Absence"
  end
end
