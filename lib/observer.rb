# frozen_string_literal: true

class Observer
  attr_reader :storage, :scrapper, :notifier

  def initialize(scrapper:, notifier:, storage: Hash.new)
    @scrapper = scrapper
    @storage = storage
    @notifier = notifier
  end

  def refresh
    links = scrapper.offer_links

    puts "Found #{links.count} offers."

    links.each do |link|
      if storage[link].nil?
        puts "Found new flat, saving the link in storage..."

        storage[link] = link

        send_notification(link)
      end
    end
  end

  def cold_start
    puts 'Run cold start'

    scrapper.offer_links.each do |link|
      storage[link] = link
    end
  end

  private

  def send_notification(link)
    notifier.send_message(
      chat_id: ENV["TELEGRAM_ACCOUNT_ID"],
      text: <<~MESSAGE
        Sup mate, I've found a new flat 😎
        Check this out!
        Link: -> #{link}
      MESSAGE
    )

    puts "Notification for #{link} sent."
  end
end
