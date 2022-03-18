require 'scrapper'
require 'redis'
require 'telegram/bot'

class Server
  OTODOM = 'https://www.otodom.pl/'

  attr_reader :redis, :scrapper, :bot

  def initialize
    @scrapper = Scrapper.new
    @redis = Redis.new
    @bot = Telegram::Bot::Client.new(ENV["TELEGRAM_TOKEN"])
  end

  def start
    cold_start

    loop do
      links = scrapper.offer_links

      links.each do |link|
        unless redis.exists(link).positive?
          redis.set(link, 1)

          send_notification(link)
        end
      end

      sleep(600) # 10 minutes
    end
  end

  private

  def send_notification(link)
    bot.api.send_message(
      chat_id: ENV["TELEGRAM_ACCOUNT_ID"],
      text: <<~MESSAGE
        Sup mate, I've found a new flat 😎
        Check this out!
        Link: -> #{OTODOM}/#{link}
      MESSAGE
    )
  end


  def cold_start
    scrapper.offer_links.each do |link|
      redis.set(link, 1)
    end
  end
end

Server.new.start
