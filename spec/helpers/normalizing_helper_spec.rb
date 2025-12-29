require 'rails_helper'
RSpec.describe NormalizingHelper do
  describe '.normalize_email_address' do
    context 'with valid email addresses' do
      it 'strips whitespace and downcases' do
        expect(described_class.normalize_email_address(' User@Example.COM ')).to eq('user@example.com')
      end

      it 'preserves the email structure while normalizing' do
        expect(described_class.normalize_email_address('First.Last+Tag@Example.COM')).to eq('first.last+tag@example.com')
      end

      it 'handles already normalized emails' do
        expect(described_class.normalize_email_address('user@example.com')).to eq('user@example.com')
      end
    end

    context 'with invalid input' do
      it 'returns an empty string for empty input' do
        expect(described_class.normalize_email_address('')).to eq("")
      end

      it 'handles string with only whitespace' do
        expect(described_class.normalize_email_address('   ')).to eq("")
      end
    end
  end
end
