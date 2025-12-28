module WeightUnits
  GRAMS = "grams"
  KILOGRAMS = "kilograms"
  OUNCES = "ounces"
  POUNDS = "pounds"
  STONES = "stones"

  class << self
    def grams; GRAMS end
    def kilograms; KILOGRAMS end
    def ounces; OUNCES end
    def pounds; POUNDS end
    def stones; STONES end

    def all
      [GRAMS, KILOGRAMS, OUNCES, POUNDS, STONES]
    end
  end
end
