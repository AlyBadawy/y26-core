module LengthConverter
  extend self

  def cm_to_inches_and_feet(cm)
    total_inches = cm.to_f / 2.54
    feet = (total_inches / 12).floor
    inches = (total_inches % 12).round(0)
    { feet: feet, inches: inches }
  end

  def inches_and_feet_to_cm(feet, inches)
    total_inches = (feet.to_i * 12) + inches.to_f
    (total_inches * 2.54).round(0)
  end
end
