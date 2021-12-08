# frozen_string_literal: true

class WebhooksController < ApplicationController
  def create
    body = request.body
    signature = request.headers['x-jebbit-signature']

    Rails.logger.info("Request Headers:")
    headers = request.env.select {|k,v|
      k.match("^HTTP.*|^CONTENT.*|^REMOTE.*|^REQUEST.*|^AUTHORIZATION.*|^SCRIPT.*|^SERVER.*")
    }
    Rails.logger.info(headers.to_json)

    Rails.logger.info("Request Body:")
    Rails.logger.info(body.to_json)

    webhooks_service = JebbitWebhooksService.new(body, signature)

    return head :forbidden unless webhooks_service.verify_signature

    Rails.logger.info("Signature verified")

    if request.headers['x-jebbit-test']
      Rails.logger.info("Test Webhook header detected.")
    else
      Rails.logger.info("Real Webhook detected.")
    end

    head :ok
  rescue StandardError
    head :bad_request
  end
end
