require "toddler/version"
require "toddler/visit_data"
require "toddler/crawler"

module Toddler
  def self.new(base_url, debug: false)
    Toddler::Crawler.new(base_url, debug: debug)
  end
end
