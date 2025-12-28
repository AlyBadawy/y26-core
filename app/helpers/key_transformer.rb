module KeyTransformer
  extend self

  def camelize(str, upper = false)
    new_str = str.to_s.strip.gsub(/\s+/, "_")

    if upper
      new_str.camelize
    else
      new_str.camelize(:lower)
    end
  end

  def self.underscore(str)
    str.to_s.underscore
  end

  def self.deep_transform_keys(obj, &block)
    case obj
    when Hash
      obj.transform_keys(&block).transform_values { |v| deep_transform_keys(v, &block) }
    when Array
      obj.map { |e| deep_transform_keys(e, &block) }
    else
      obj
    end
  end
end
