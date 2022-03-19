require 'scrapper'
require 'redis'
require 'telegram/bot'

class Server
  OTODOM = 'https://www.otodom.pl/'

  attr_reader :storage, :scrapper, :bot

  def initialize
    @scrapper = Scrapper.new
    # @redis = Redis.new
    @storage = Hash.new
    @bot = Telegram::Bot::Client.new(ENV["TELEGRAM_TOKEN"])
  end

  def start
    puts 'Start server...'

    cold_start

    loop do
      puts 'Fetching links...'

      links = scrapper.offer_links

      puts "Found #{links.count} offers"

      links.each do |link|
        # unless redis.exists(link).positive?
        if storage[link].nil?
          puts "Found new flat, saving the link in storage..."

          # redis.set(link, 1)
          storage[link] = link

          send_notification(link)

          puts "Notification for #{link} sent."
        end
      end

      puts "Start waiting..."

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
    puts 'Run cold start'

    scrapper.offer_links.each do |link|
      storage[link] = link
    end
  end
end
