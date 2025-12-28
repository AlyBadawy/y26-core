require "rails_helper"

RSpec.describe TransformRequestKeys do
  let(:app) do
    # simple downstream app that returns the raw request body
    lambda do |env|
      body = env["rack.input"].read
      [200, { "Content-Type" => "application/json" }, [body]]
    end
  end

  let(:middleware) { described_class.new(app) }

  def call_with_body(body)
    env = {
      "rack.input" => StringIO.new(body),
      "CONTENT_LENGTH" => body.bytesize.to_s,
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/test",
    }

    status, headers, response = middleware.call(env)
    [env, status, headers, response]
  end

  it "transforms top-level and nested hash keys from camelCase to snake_case and updates CONTENT_LENGTH" do
    body = { "someKey" => "value", "nestedObject" => { "innerKey" => 1 } }.to_json
    env, status, _headers, response = call_with_body(body)

    expect(status).to eq(200)

    transformed = JSON.parse(response.join)
    expect(transformed).to eq({ "some_key" => "value", "nested_object" => { "inner_key" => 1 } })

    expect(env["CONTENT_LENGTH"]).to eq(env["rack.input"].size.to_s)
  end

  it "leaves non-JSON bodies unchanged" do
    body = "not json"
  _env, status, _headers, response = call_with_body(body)

    expect(status).to eq(200)
    expect(response.join).to eq("not json")
  end

  it "does not transform JSON arrays (only transforms when parsed body is a Hash)" do
    body = [{ "aKey" => 1 }].to_json
    _env, status, _headers, response = call_with_body(body)

    expect(status).to eq(200)
    parsed = JSON.parse(response.join)
    expect(parsed).to eq([{ "aKey" => 1 }])
  end

  it "handles empty request body without modifying env and returns empty body" do
    env, status, _headers, response = call_with_body("")

    expect(status).to eq(200)
    expect(response.join).to eq("")
    expect(env["CONTENT_LENGTH"]).to eq("0")
  end
end
