require "rails_helper"

RSpec.describe KeyTransformer do
  describe ".camelize" do
    it "converts strings with spaces to lower camelCase by default" do
      expect(described_class.camelize(" hello world ")).to eq("helloWorld")
    end

    it "converts strings to UpperCamelCase when upper is true" do
      expect(described_class.camelize("hello world", true)).to eq("HelloWorld")
    end

    it "handles already underscored strings" do
      expect(described_class.camelize("some_value_here")).to eq("someValueHere")
    end
  end

  describe ".underscore" do
    it "converts CamelCase to snake_case" do
      expect(described_class.underscore("HelloWorldTest")).to eq("hello_world_test")
    end
  end

  describe ".deep_transform_keys" do
    it "recursively transforms keys in nested hashes" do
      input = { 'a' => { 'b' => 1, 'c_d' => { 'e_f' => 2 } } }
      result = described_class.deep_transform_keys(input) { |k| described_class.camelize(k) }

      expect(result).to be_a(Hash)
      expect(result.keys).to include("a")
      expect(result["a"].keys).to include("b", "cD")
      expect(result["a"]["cD"].keys).to include("eF")
      expect(result["a"]["cD"]["eF"]).to eq(2)
    end

    it "transforms keys inside arrays of hashes" do
      input = { 'items' => [{ 'id' => 1 }, { 'id' => 2 }] }
      result = described_class.deep_transform_keys(input) { |k| k.to_sym }

      expect(result).to have_key(:items)
      expect(result[:items]).to be_an(Array)
      expect(result[:items].first).to have_key(:id)
      expect(result[:items].first[:id]).to eq(1)
    end

    it "returns non-hash/array values unchanged" do
      expect(described_class.deep_transform_keys(42)).to eq(42)
      expect(described_class.deep_transform_keys("string")).to eq("string")
    end
  end
end
