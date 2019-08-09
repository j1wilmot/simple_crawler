require "simple_crawler/version"
require "simple_crawler/visit_data"
require "simple_crawler/crawler"

module SimpleCrawler
  class Error < StandardError; end

  def self.new(base_url, debug: false)
    Crawler.new(base_url, debug: debug)
  end
end
