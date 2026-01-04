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

    # Also transform any params present in the query string.
    if env["QUERY_STRING"] && !env["QUERY_STRING"].strip.empty?
      begin
        require "rack"
        query_hash = Rack::Utils.parse_nested_query(env["QUERY_STRING"]) rescue nil
        if query_hash.is_a?(Hash) && !query_hash.empty?
          transformed_query = KeyTransformer.deep_transform_keys(query_hash) { |key| KeyTransformer.underscore(key) }
          new_query = Rack::Utils.build_nested_query(transformed_query)

          env["QUERY_STRING"] = new_query
          # Update Rack's cached request query data if present so downstream uses the transformed values.
          env.delete("rack.request.query_hash")
          env.delete("rack.request.query_string")
          env["rack.request.query_hash"] = transformed_query
          env["rack.request.query_string"] = new_query
        end
      rescue => e
        # If parsing fails for any reason, silently ignore and proceed with original env.
      end
    end

    @app.call(env)
  end
end
