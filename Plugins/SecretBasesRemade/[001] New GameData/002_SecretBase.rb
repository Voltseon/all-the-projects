module GameData
  class SecretBase
    attr_reader :id
    attr_reader :map_template
    attr_reader :location

    DATA = {}
    DATA_FILENAME = "secret_bases.dat"

    extend ClassMethodsSymbols
    include InstanceMethods

    SCHEMA = {
      "MapTemplate"  => [:map_template, "e", :SecretBaseTemplate],
      "Location"     => [:location, "vuu"]
    }

    def initialize(hash)
      @id               = hash[:id]
      @map_template     = hash[:map_template]
      @location         = hash[:location]
    end
  end
end