$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "toddler"

require "webmock/minitest"
WebMock.disable_net_connect!

require "minitest/autorun"
