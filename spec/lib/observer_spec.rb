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
  end
end
