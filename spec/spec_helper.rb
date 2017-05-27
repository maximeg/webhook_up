# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "webhook_up"

require "webmock/rspec"
WebMock.disable_net_connect!
