# frozen_string_literal: true

require 'openssl'

TOLERANCE = 300

class JebbitWebhooksService
  attr_reader :body, :shared_secret, :signature, :timestamp, :hmac

  def initialize(body, signature)
    @shared_secret = Rails.application.credentials.jebbit[:webhook_shared_secret]
    @body = body
    @signature = signature

    decomposed_signature = decompose_signature(@signature)
    @timestamp = decomposed_signature.first
    @hmac = decomposed_signature.last
  end

  def verify_signature
    generated_payload = "#{@timestamp}.#{@body}"

    if TOLERANCE && @timestamp < Time.now.to_i - TOLERANCE
      raise StandardError, 'Timestamp outside of tolerance'
    end

    calculated_hmac = Base64.strict_encode64(
      OpenSSL::HMAC.digest('sha256', @shared_secret, generated_payload)
    )
    ActiveSupport::SecurityUtils.secure_compare(@hmac, calculated_hmac)
  end

  private

  def decompose_signature(signature)
    signature_items = signature.split(',')
    timestamp = Integer(signature_items.first.split('=', 2).last)
    hmac = signature_items.last.split('=', 2).last
    [timestamp, hmac]
  end
end
