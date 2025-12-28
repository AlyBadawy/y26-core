class TransformResponseKeys
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    if headers["Content-Type"]&.include?("application/json")
      body = ""
      response.each { |part| body << part }

      # If there's no body, or it's not valid JSON, skip transformation.
      begin
        return [status, headers, response] if body.nil? || body.strip.empty?

        parsed_body = JSON.parse(body)
      rescue JSON::ParserError
        return [status, headers, response]
      end

      transformed_body = KeyTransformer.deep_transform_keys(parsed_body) do |key|
        KeyTransformer.camelize(key)
      end

      new_body = [transformed_body.to_json]
      headers["Content-Length"] = new_body.sum(&:bytesize).to_s
      [status, headers, new_body]
    else
      [status, headers, response]
    end
  end
end
