class Profile
  attr_accessor :name
  attr_accessor :is_female
  attr_accessor :outfit
  attr_accessor :online_id
  attr_accessor :party

  def initialize
    @name           = $Trainer.name
    @is_female      = $Trainer.isFemale?
    @outfit         = $Trainer.outfit
    @online_id      = $Trainer.secret_ID
    @party          = $Trainer.party
  end

  def name;         return @name;               end
  def is_female;    return @is_female;          end
  def outfit;       return $Trainer.outfit;     end
  def online_id;    return @online_id;          end
  def party;        return $Trainer.party;      end
end