describe AuthConfiguration do
  describe ".refresh_token_duration" do
    it "returns the refresh token duration" do
      expect(described_class.refresh_token_duration).to eq(1.week)
    end
  end

  describe ".session_secret" do
    context "when SESSION_SECRET environment variable is set" do
      before do
        stub_const('ENV', ENV.to_hash.merge('SESSION_SECRET' => 'my_secret_key'))
      end

      it "returns the session secret from the environment variable" do
        expect(described_class.session_secret).to eq("my_secret_key")
      end
    end

    context "when SESSION_SECRET environment variable is not set" do
      before do
        stub_const('ENV', ENV.to_hash.merge('SESSION_SECRET' => nil))
      end

      it "returns the default session secret" do
        expect(described_class.session_secret).to eq("default_session_secret")
      end
    end
  end
end
