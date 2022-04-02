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

    new_links = links.map do |link|
      if storage[link].nil?
        puts "Found new flat, saving the link in storage..."
        storage[link] = link
      end
    end.compact

    send_notification(new_links) if new_links.any?
  end

  def cold_start
    puts 'Run cold start'

    scrapper.offer_links.each do |link|
      storage[link] = link
    end
  end

  private

  def send_notification(links)
    notifier.send_message(
      chat_id: ENV["TELEGRAM_CHAT_ID"],
      text: <<~MESSAGE
        Yo bro, I've got something new for you! ヽ(^。^)丿 Wanna see? (⌐■_■)
        It's yours 彡ﾟ◉ω◉ )つー☆*
        #{links.map.with_index {|link, index| "#{index + 1}. #{link}"}.join("\n")}
      MESSAGE
    )

    puts "Sent notification of #{links.count} new flats"
  end
end
