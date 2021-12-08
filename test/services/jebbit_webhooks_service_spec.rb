require 'rails_helper'

SHARED_SECRET = '$super_secure_shared_secret!'.freeze

describe 'JebbitWebhooksService' do
  subject { described_class }

  before do
    allow(ENV).to receive(:WEBHOOK_SHARED_SECRET).and_return(SHARED_SECRET)
  end

  context 'when given a body and signature' do
    let!(:body) do
      {}.to_json
    end
    let!(:signature) do
      generate_signature(body)
    end

    it 'initializes properly' do
      webhooks_service = JebbitWebhooksService.new(body, signature)
      expect(webhooks_service.body).to eq(body)
      expect(webhooks_service.signature).to eq(signature)
    end
  end

  context 'when given a body and valid signature' do
    let!(:body) do
      { data: { testData: 'hello_world' } }.to_json
    end
    let!(:signature) do
      generate_signature(body)
    end

    it 'validates' do
      webhooks_service = JebbitWebhooksService.new(body, signature)
      expect(webhooks_service.verify_signature).to be(true)
    end
  end

  context 'when given a body and invalid timestamp' do
    let!(:body) do
      { data: { testData: 'hello_world' } }.to_json
    end
    let!(:signature) do
      't=123561,v1=abc123'
    end

    it 'raises error' do
      webhooks_service = JebbitWebhooksService.new(body, signature)
      expect { webhooks_service.verify_signature }.to raise_error(
        StandardError, 'Timestamp outside of tolerance'
      )
    end
  end

  context 'when given a body, timestamp and invalid signature' do
    let!(:body) do
      { data: { testData: 'hello_world' } }.to_json
    end
    let!(:signature) do
      "t=#{Time.now.to_i},v1=abc123"
    end

    it 'returns false' do
      webhooks_service = JebbitWebhooksService.new(body, signature)
      expect(webhooks_service.verify_signature).to be(false)
    end
  end
end

def generate_signature(body)
  timestamp = Time.now.to_i
  payload = "#{timestamp}.#{body}"
  hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SHARED_SECRET,
                                                     payload))
  "t=#{timestamp},v1=#{hmac}"
end
