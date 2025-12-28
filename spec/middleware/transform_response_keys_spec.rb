require "rails_helper"

RSpec.describe TransformResponseKeys do
  def build_middleware_with(body, headers = {})
    app = lambda do |env|
      [200, headers.merge({ "Content-Length" => body.bytesize.to_s }), [body]]
    end

    described_class.new(app)
  end

  it "transforms JSON response keys from snake_case to camelCase and updates Content-Length" do
    body = { "some_key" => "value", "nested_object" => { "inner_key" => 1 } }.to_json
    mw = build_middleware_with(body, { "Content-Type" => "application/json" })

  status, _headers, response = mw.call({})
  expect(status).to eq(200)

  parsed = JSON.parse(response.join)
  expect(parsed).to eq({ "someKey" => "value", "nestedObject" => { "innerKey" => 1 } })
  end

  it "transforms JSON arrays in the response" do
    body = [{ "a_key" => 1 }, { "b_key" => 2 }].to_json
    mw = build_middleware_with(body, { "Content-Type" => "application/json; charset=utf-8" })

  status, _headers, response = mw.call({})
    expect(status).to eq(200)

    parsed = JSON.parse(response.join)
    expect(parsed).to eq([{ "aKey" => 1 }, { "bKey" => 2 }])
  end

  it "returns original response for non-JSON content types" do
    body = "plain text"
    original_headers = { "Content-Type" => "text/plain", "Content-Length" => body.bytesize.to_s }
    app = lambda { |_env| [202, original_headers.dup, [body]] }
    mw = described_class.new(app)

    status, headers, response = mw.call({})
    expect(status).to eq(202)
    expect(headers).to eq(original_headers)
    expect(response).to eq([body])
  end

  it "leaves response untouched when Content-Type header is not defined" do
    body = { "some_key" => "value" }.to_json
    original_headers = { "Content-Length" => body.bytesize.to_s }
    app = lambda { |_env| [200, original_headers.dup, [body]] }
    mw = described_class.new(app)

    status, headers, response = mw.call({})

    expect(status).to eq(200)
    expect(headers).to eq(original_headers)
    expect(response).to eq([body])
  end

  it "handles empty response body gracefully" do
    body = ""
    mw = build_middleware_with(body, { "Content-Type" => "application/json" })

    status, headers, response = mw.call({})

    expect(status).to eq(200)
    expect(headers["Content-Length"]).to eq("0")
    expect(response).to eq([body])
  end

  it "handles invalid JSON body gracefully" do
    body = "invalid json"
    mw = build_middleware_with(body, { "Content-Type" => "application/json" })

    status, headers, response = mw.call({})

    expect(status).to eq(200)
    expect(headers["Content-Length"]).to eq(body.bytesize.to_s)
    expect(response).to eq([body])
  end
end
