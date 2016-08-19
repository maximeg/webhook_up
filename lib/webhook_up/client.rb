# frozen_string_literal: true
require "faraday"
require 'securerandom'

module WebhookUp

  class Client

    class << self

      def generate_challenge
        SecureRandom.hex(20)
      end

    end

    def initialize(url, namespace:, secret:)
      @namespace = namespace
      @secret = secret
      @url = url
    end

    attr_reader :url

    def challenge
      challenge_string = self.class.generate_challenge

      signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), secret, challenge_string)

      response = connexion.get do |req|
        req.headers["X-Hub-Signature"] = signature
        req.headers["User-Agent"] = user_agent
        req.params.merge!({
          "hub.challenge" => challenge_string,
          "hub.mode" => "subscribe"
        })
      end

      Response.new(url, status: response.status, body: response.body, headers: response.headers)
    end

    def publish(event, payload:, delivery_id: nil)
      json_payload = JSON.dump(payload)
      signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), secret, json_payload)

      delivery_id ||= Digest::SHA1.hexdigest(json_payload)

      response = connexion.post do |req|
        req.headers["X-Hub-Signature"] = signature
        req.headers["X-#{namespaced_header}-Delivery"] = delivery_id
        req.headers["X-#{namespaced_header}-Event"] = event
        req.headers["User-Agent"] = user_agent
        req.headers["Content-Type"] = "application/json"
        req.body = json_payload
      end

      Response.new(url, status: response.status, body: response.body, headers: response.headers)
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
