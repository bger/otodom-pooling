# frozen_string_literal: true

require 'spec_helper'
require 'observer'
require 'otodom_scrapper'

RSpec.describe Observer do
  subject(:observer) { described_class.new(scrapper: scrapper, notifier: notifier, storage: storage) }

  let(:scrapper) { instance_double(OtodomScrapper, offer_links: flats) }
  let(:notifier) do
    Class.new do
      def messages
        @messages ||= []
      end

      def send_message(chat_id:, text:)
        messages << {chat_id: chat_id, text: text}
      end
    end.new
  end
  let(:storage) { Hash.new }

  before(:all) do
    $stdout = open('/dev/null', 'w')
  end
  after(:all) do
    $stdout = STDOUT
  end

  describe '#refresh' do
    context "when there is a new flat" do
      let(:flats) { ['link1', 'new_flat'] }
      let(:storage) { {'link1' => 'link1'} }

      it 'puts it to the storage' do
        observer.refresh

        expect(storage['new_flat']).not_to be_nil
      end

      it 'sends notification message' do
        observer.refresh

        expect(notifier.messages.count).to eq(1)
        expect(notifier)
      end
    end

    context "when there are many new flats" do
      let(:flats) { ['flat1', '_flat2', '_flat3'] }
      let(:storage) { {'flat1' => 'flat1'} }

      it 'puts them to the storage' do
        observer.refresh

        expect(storage.keys).to include('_flat2', '_flat3')
      end

      it 'sends notification message' do
        observer.refresh

        expect(notifier.messages.count).to eq(1)

        expect(notifier.messages.first[:text]).to eq(<<~MESSAGE
          Yo bro, I've got something new for you! ヽ(^。^)丿 Wanna see? (⌐■_■)
          It's yours 彡ﾟ◉ω◉ )つー☆*
          1. _flat2
          2. _flat3
        MESSAGE
        )
      end
    end
  end

  describe '#cold_start' do
    let(:flats) { ['link1', 'new_flat'] }
    let(:storage) { {} }

    it 'puts all links into storage' do
      expect { observer.cold_start }.to change { storage.count }.from(0).to(2)
    end

    it "doesn't send notification messages" do
      observer.cold_start

      expect(notifier.messages.count).to eq(0)
    end
  end
end
