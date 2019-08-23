module Toddler
  class VisitData
    attr_reader :path, :linked_paths, :document
    def initialize(path, linked_paths, document)
      @path = path
      @linked_paths = linked_paths
      @document = document
    end

    def to_s
      {path: path, links: links}.to_s
    end

    def inspect
      "<VisitData path='#{path}' " +
        "linked_paths=[#{linked_paths.inspect}] " +
        "document='#{document[0..10]}...'>"
    end
  end
end
