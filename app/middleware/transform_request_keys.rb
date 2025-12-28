class TransformRequestKeys
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["rack.input"]
      request_body = env["rack.input"].read
      env["rack.input"].rewind

      unless request_body.empty?
        parsed_body = JSON.parse(request_body) rescue nil
        if parsed_body.is_a?(Hash)
          transformed_body = KeyTransformer.deep_transform_keys(parsed_body) { |key| KeyTransformer.underscore(key) }
          env["rack.input"] = StringIO.new(transformed_body.to_json)
          env["CONTENT_LENGTH"] = env["rack.input"].size.to_s
        end
      end
    end

    @app.call(env)
  end
end
