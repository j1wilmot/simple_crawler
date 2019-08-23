require 'set'
require 'faraday'

# Follow all relative paths on pages in a domain
# This is single threaded so it isn't particularly fast and won't DDOS sites
# Should check sites' robot.txt before using to ensure sites allow crawling
module Toddler
  class Crawler
    attr_reader :visited_paths, :queued_paths, :paths_to_pages
    attr_accessor :debug

    def initialize(base_url, debug: false)
      @visited_paths = Set.new
      @queued_paths = []
      @paths_to_pages = {}
      @debug = debug
      @fetcher = Faraday.new(base_url, request: { timeout: 2 })
    end

    def fetch(path)
      puts "Fetching #{path}..." if @debug
      start_time = Time.now
      @visited_paths.add path
      body = @fetcher.get(path).body
      puts "Fetched #{path} in #{Time.now - start_time}" if @debug
      body
    end

    def find_relative_links(page)
      page
        .scan(/<a.*?href="(.*?)"/)
        .flatten
        .select { |link| link.start_with?('/') }
    end

    def visit_path(path)
      add_visited_path path
      document = fetch(path)
      links = find_relative_links(document)
      VisitData.new path, links, document
    end

    def path_visited?(path)
      @visited_paths.include?(path)
    end

    def visit_next_path
      path = next_path!
      return nil if path.nil? || path_visited?(path)
      page_data = visit_path path
      store_page_data page_data
      queue_up_paths page_data.linked_paths
      page_data
    end

    def crawl(starting_path)
      add_path_to_queue starting_path
      visit_next_path while has_next_path?
      @paths_to_pages
    end

    def queue_up_paths(paths)
      paths.
        select {|path| !path_visited?(path) }.
        each {|path| add_path_to_queue(path) }
    end

    def next_path!
      @queued_paths.shift
    end

    def next_path
      @queued_paths.first
    end

    def has_next_path?
      !@queued_paths.empty?
    end

    def add_visited_path(path)
      @visited_paths.add path
    end

    def add_path_to_queue(path)
      @queued_paths << path
    end

    def store_page_data(data)
      @paths_to_pages[data.path] = data
    end
  end
end
