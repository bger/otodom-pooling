# frozen_string_literal: true

class OtodomScrapper
  BASE_URI = "https://www.otodom.pl"

  def offer_links
    page_number = 1
    links = Set.new

    loop do
      page = HTTParty.get(ENV['OTODOM_URL'].gsub(/page=./, "page=#{page_number}"))
      node = Nokogiri::HTML(page.body)

      break if node.search("//@data-cy='no-search-results'")

      node
        .search("//div[@data-cy='search.listing']//a[@data-cy='listing-item-link']")
        .map { |link| links << "#{BASE_URI}#{link.attributes['href'].value}" }

      page_number += 1
    end

    links
  end
end
