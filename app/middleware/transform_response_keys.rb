class TransformResponseKeys
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if json_content?(headers)
      body = extract_body(response)
      return [status, headers, response] if body.nil? || body.strip.empty?

      parsed = parse_json(body)
      return [status, headers, response] unless parsed

      transformed_body = transform_body_keys(parsed)

      transform_header_urls(headers)

      new_body = build_response_body(transformed_body)
      headers["Content-Length"] = new_body.sum(&:bytesize).to_s
      [status, headers, new_body]
    else
      [status, headers, response]
    end
  end

  private

  def json_content?(headers)
    headers["Content-Type"]&.include?("application/json")
  end

  def extract_body(response)
    body = ""
    response.each { |part| body << part }
    body
  end

  def parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end

  def transform_body_keys(parsed)
    KeyTransformer.deep_transform_keys(parsed) do |key|
      KeyTransformer.camelize(key)
    end
  end

  def build_response_body(transformed_body)
    [transformed_body.to_json]
  end

  def transform_header_urls(headers)
    require "uri"
    require "rack"

    transform_location_headers(headers)
    transform_link_header(headers)
  rescue => _e
    # ignore header-query transformation failures
  end

  def transform_location_headers(headers)
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
  end

  def transform_link_header(headers)
    return unless headers["Link"]
    headers["Link"] = headers["Link"].gsub(/<([^>]+)>/) do |m|
      url = $1
      begin
        uri = URI.parse(url)
        next m unless uri&.query&.length.to_i > 0

        qhash = Rack::Utils.parse_nested_query(uri.query)
        next m unless qhash.is_a?(Hash) && qhash.any?

        uri.query = Rack::Utils.build_nested_query(
          KeyTransformer.deep_transform_keys(qhash) { |k| KeyTransformer.camelize(k) }
        )

        "<#{uri}>"
      rescue StandardError
        m
      end
    end
  end
end
