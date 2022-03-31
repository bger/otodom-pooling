# frozen_string_literal: true

class OlxScrapper
  BASE_URI = "https://www.olx.pl/"
  FIRST_PAGE_URL = "https://www.olx.pl/nieruchomosci/mieszkania/wynajem/krakow/?search%5Bfilter_float_price%3Afrom%5D=2500&search%5Bfilter_float_price%3Ato%5D=3000&search%5Bfilter_float_m%3Afrom%5D=40"

  def offer_links
    page_number = 1
    offers = Set.new

    first_node = Nokogiri::HTML(HTTParty.get(FIRST_PAGE_URL).body)

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
