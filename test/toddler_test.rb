require "test_helper"

class SimpleCrawlerTest < Minitest::Test
  def setup
    @crawler = Toddler.new('http://www.example.com')
  end

  def test_crawler_finds_links
    doc = '<a href="/cats"></a><a href="/dogs"></a>'
    expected = ['/cats', '/dogs']
    assert_equal expected, @crawler.find_relative_links(doc)
  end

  def test_crawler_fetches_pages
    doc = "<div>sample html doc</div>"
    stub_request(:get, 'www.example.com/doc').
      to_return(body: doc)
    assert_equal doc, @crawler.fetch("/doc")
  end

  def test_queuing_and_visiting_paths
    assert_equal [], @crawler.queued_paths
    @crawler.queue_up_paths(['/dogs', '/cats'])
    assert_equal ['/dogs', '/cats'], @crawler.queued_paths
    stub_request(:get, 'www.example.com/dogs').
      to_return(body: '')
    @crawler.visit_next_path
    assert @crawler.visited_paths.include? '/dogs'
    @crawler.queue_up_paths(['/dogs', '/monkeys'])
    assert_equal ['/cats', '/monkeys'], @crawler.queued_paths
  end

  def test_crawler_visits_paths
    path = '/dogs'
    links = ['/cats', '/rabbits']
    doc = '<a href="/cats"></a></a><a href="/rabbits"></a>'
    stub_request(:get, 'www.example.com/dogs').
      to_return(body: doc)
    page_data = @crawler.visit_path(path)
    assert_equal path, page_data.path
    assert_equal links, page_data.linked_paths
    assert_equal doc, page_data.document
    assert @crawler.visited_paths.include?(path)
  end

  def test_do_not_visit_already_visited_page
    root_body = '<a href="/">'
    stub_request(:get, 'www.example.com/').
      to_return(body: root_body)

    3.times do
      @crawler.add_path_to_queue('/')
      @crawler.visit_next_path
    end

    assert_requested :get, 'www.example.com/', times: 1
  end

  def test_crawler_crawls_basic_site
    root_body = '<a href="/users">'
    stub_request(:get, 'www.example.com/').
      to_return(body: root_body)
    users_body = '<a href="/passwords">'
    stub_request(:get, 'www.example.com/users').
      to_return(body: users_body)
    password_body = ''
    stub_request(:get, 'www.example.com/passwords').
      to_return(body: password_body)

    crawl_data = @crawler.crawl('/')
    assert_equal ['/', '/users', '/passwords'], crawl_data.keys
    assert_equal root_body, crawl_data['/'].document
    assert_equal users_body, crawl_data['/users'].document
    assert_equal password_body, crawl_data['/passwords'].document
  end
end
