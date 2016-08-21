# frozen_string_literal: true
require "faraday"
require "securerandom"

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

      response = request(:get) do |req|
        req.headers["X-Hub-Signature"] = sign(challenge_string)
        req.params.merge!({
          "hub.challenge" => challenge_string,
          "hub.mode" => "subscribe",
        })
      end

      response = Response.new(url, status: response.status, body: response.body, headers: response.headers)
      success = response.success? && response.body == challenge_string

      Result.new(response: response, success: success)
    end

    def publish(event, payload:, delivery_id: nil)
      json_payload = JSON.dump(payload)
      delivery_id ||= Digest::SHA1.hexdigest(json_payload)

      response = request(:post) do |req|
        req.headers["X-Hub-Signature"] = sign(json_payload)
        req.headers["X-#{namespaced_header}-Delivery"] = delivery_id
        req.headers["X-#{namespaced_header}-Event"] = event
        req.headers["Content-Type"] = "application/json"
        req.body = json_payload
      end

      response = Response.new(url, status: response.status, body: response.body, headers: response.headers)

      Result.new(response: response, success: response.success?)
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

    def request(method)
      connexion.send(method) do |req|
        req.headers["User-Agent"] = user_agent
        yield req
      end
    end

    def sign(string)
      "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), secret, string)
    end

    def user_agent
      "#{namespace}-Webhook"
    end

  end

end
