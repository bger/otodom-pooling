require 'mechanize'

class Scrapper
  attr_reader :path

  def initialize(path = ENV['OFFERS_URL'])
    @path = path
    @agent = Mechanize.new
  end

  def offer_links
    page = agent.get(path)

    page.search("//*[@data-cy='listing-item-link']").map { |link| link.attributes['href'].value }
  end

  private

  attr_reader :agent
end
