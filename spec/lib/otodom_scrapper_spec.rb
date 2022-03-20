# frozen_string_literal: true

require 'spec_helper'
require 'pry'
require 'otodom_scrapper'

RSpec.describe OtodomScrapper do
  subject(:scrapper) { described_class.new }

  def fixture_for(page)
    File.read(File.expand_path("../../fixtures/#{page}.html",__FILE__))
  end

  describe '#offer_links' do
    context "when there are several pages with offers" do
      before do
        stub_request(:get, /page=1/).to_return(body: fixture_for("page1"))
        stub_request(:get, /page=2/).to_return(body: fixture_for("page2"))
        stub_request(:get, /page=3/).to_return(body: fixture_for("no-offers-page"))
      end

      it 'returns all offers links' do
        expect(scrapper.offer_links.count).to eq(83)
      end

    end
  end
end
