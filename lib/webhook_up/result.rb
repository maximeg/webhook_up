# frozen_string_literal: true

require "faraday"

module WebhookUp
  class Result

    def initialize(response:, success:)
      @response = response
      @success = success
    end

    attr_reader :response, :success

    def success?
      success
    end

  end
end
