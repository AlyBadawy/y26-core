module WeightConverter
  extend self

  def convert_value(value, from_unit, to_unit)
    weight_in_grams = to_grams(value, from_unit)
    from_grams(weight_in_grams, to_unit).round(2)
  end

  private

  def to_grams(value, unit)
    case unit
    when WeightUnits.grams
      value.to_f
    when WeightUnits.kilograms
      value.to_f * 1000
    when WeightUnits.ounces
      value.to_f * 28.3495
    when WeightUnits.pounds
      value.to_f * 453.592
    when WeightUnits.stones
      value.to_f * 6350.29
    else
      raise ArgumentError, "Unsupported weight unit: #{unit}"
    end
  end

  def from_grams(value_in_grams, unit)
    case unit
    when WeightUnits.grams
      value_in_grams
    when WeightUnits.kilograms
      value_in_grams / 1000
    when WeightUnits.ounces
      value_in_grams / 28.3495
    when WeightUnits.pounds
      value_in_grams / 453.592
    when WeightUnits.stones
      value_in_grams / 6350.29
    else
      raise ArgumentError, "Unsupported weight unit: #{unit}"
    end
  end
end
