# frozen_string_literal: true

class OlxScrapper
  def offer_links
    page_number = 1
    offers = Set.new

    first_node = Nokogiri::HTML(HTTParty.get(ENV['OLX_URL']).body)

    links_to_next_pages = first_node
    .search("//div[@class='pager rel clr']/span[@class='item fleft']/a")
    .map {|page| page.attributes["href"].value }

    nodes = links_to_next_pages.map { |link| Nokogiri::HTML(HTTParty.get(link).body) }


    [first_node, *nodes].each do |node|
      node.search("//table[@id='offers_table']//a[@data-cy='listing-ad-title']")
        .each do |link|
          offers << link.attributes["href"].value.gsub(/(\?|#.*)/,'')
        end
    end

    offers
  end
end
