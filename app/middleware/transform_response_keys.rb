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

      # Also transform query params present in common header URLs (Location, Content-Location)
      begin
        require "uri"
        require "rack"

        ["Location", "Content-Location"].each do |h|
          next unless headers[h]
          begin
            uri = URI.parse(headers[h]) rescue nil
            next unless uri && uri.query && !uri.query.empty?
            qhash = Rack::Utils.parse_nested_query(uri.query) rescue nil
            if qhash.is_a?(Hash)
              new_q = Rack::Utils.build_nested_query(
                KeyTransformer.deep_transform_keys(qhash) { |k| KeyTransformer.camelize(k) }
              )
              uri.query = new_q
                headers[h] = "#{uri}"
            end
          rescue => _e
            # ignore and leave header as-is
          end
        end

        # Transform any URLs inside a Link header
        if headers["Link"]
          headers["Link"] = headers["Link"].gsub(/<([^>]+)>/) do |m|
            url = $1
            begin
              uri = URI.parse(url) rescue nil
              if uri && uri.query && !uri.query.empty?
                qhash = Rack::Utils.parse_nested_query(uri.query) rescue nil
                if qhash.is_a?(Hash)
                  new_q = Rack::Utils.build_nested_query(
                    KeyTransformer.deep_transform_keys(qhash) { |k| KeyTransformer.camelize(k) }
                  )
                  uri.query = new_q
                  "<#{uri}>"
                else
                  m
                end
              else
                m
              end
            rescue => _e
              m
            end
          end
        end
      rescue => _e
        # ignore header-query transformation failures
      end

      new_body = [transformed_body.to_json]
      headers["Content-Length"] = new_body.sum(&:bytesize).to_s
      [status, headers, new_body]
    else
      [status, headers, response]
    end
  end
end
