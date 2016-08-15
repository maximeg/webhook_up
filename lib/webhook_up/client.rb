# frozen_string_literal: true
require "faraday"

module WebhookUp

  class Client

    def initialize(url, namespace:, secret:)
      @namespace = namespace
      @secret = secret
      @url = url
    end

    attr_reader :url

    def challenge
    end

    def publish(event, payload:, delivery_id: nil)
      json_payload = JSON.dump(payload)
      signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), secret, json_payload)

      delivery_id ||= Digest::SHA1.hexdigest(json_payload)

      connexion.post do |req|
        req.headers["X-Hub-Signature"] = signature
        req.headers["X-#{namespaced_header}-Delivery"] = delivery_id
        req.headers["X-#{namespaced_header}-Event"] = event
        req.headers["User-Agent"] = user_agent
        req.headers["Content-Type"] = "application/json"
        req.body = json_payload
      end
    end

    private

    attr_reader :namespace, :secret

    def connexion
      @connexion = Faraday.new(url: url) do |faraday|
        # faraday.request  :url_encoded
        # faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def namespaced_header
      namespace
    end

    def user_agent
      "#{namespace}-Webhook"
    end

  end

end
