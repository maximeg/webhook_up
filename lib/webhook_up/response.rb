# frozen_string_literal: true
require "faraday"

module WebhookUp

  class Response

    def initialize(url, status:, body: nil, headers: {})
      @body = body
      @headers = headers
      @status = status
      @url = url
    end

    attr_reader :body, :headers, :status, :url

    def success?
      status >= 200 && status < 300
    end

  end

end
