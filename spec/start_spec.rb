require 'spec_helper'

RSpec.describe 'bin/start' do
  before { ENV["TIMER"] = nil }

  it 'runs everything' do
    system `bin/start`
  end
end
