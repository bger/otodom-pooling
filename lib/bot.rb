require 'telegram/bot'

token = ENV['TELEGRAM_TOKEN']

puts 'Starting the server'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/ping'
      bot.api.send_message(chat_id: ENV["TELEGRAM_ACCOUNT_ID"], text: "Pong, #{message.from.username}")
    when '/start'
      question = 'London is a capital of which country?'
      # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
      answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: [%w(A B), %w(C D)], one_time_keyboard: true)
      bot.api.send_message(chat_id: ENV["TELEGRAM_ACCOUNT_ID"], text: question, reply_markup: answers)
    when '/stop'
      # See more: https://core.telegram.org/bots/api#replykeyboardremove
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(chat_id: ENV["TELEGRAM_ACCOUNT_ID"], text: 'Sorry to see you go :(', reply_markup: kb)
    end
  end
end
