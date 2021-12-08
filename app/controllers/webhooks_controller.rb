# frozen_string_literal: true

class WebhooksController < ApplicationController
  def create
    body = request.body
    signature = request.headers['x-jebbit-signature']

    Rails.logger.info("Request Headers:")
    Rails.logger.info(request.headers.to_json)

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
