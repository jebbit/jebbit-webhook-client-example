# frozen_string_literal: true

class WebhooksController < ApplicationController
  def create
    body = request.body
    signature = request.headers['x-jebbit-signature']

    webhooks_service = JebbitWebhooksService.new(body, signature)

    return head :forbidden unless webhooks_service.verify_signature

    if request.headers['x-jebbit-test']
      # do not persist data
    else
      # continue processing and persisting data
    end

    head :ok
  rescue StandardError
    head :bad_request
  end
end
