# Toddler

A simple page crawler that can incrementally crawl through pages on a domain by
following links with relative paths.

## Usage

Instantiate a new instance:
```ruby
domain = 'http://www.example.com'
crawler = Toddler.new(domain)
```

To incrementally crawl:
```ruby
crawler.queue_up_paths(['/dogs', '/cats'])
visit_data = crawler.visit_next_path
new_paths = visit_data.linked_paths
```

To do a full site crawl, starting at the base path:
```ruby
crawler.crawl('/')
```

The crawler stores all pages it crawls, so after crawling you can operate on
the page data:
```ruby
# See which pages were visited
visited_pages = crawler.visited_paths

# Find paths to all pages with a <h4> tag
pages_with_h4_tag = crawler.
  pages_to_paths.
  select{|path, data| data.document.index('<h4')}.
  map{|k,v| k}
```
