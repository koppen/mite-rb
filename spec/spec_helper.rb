require 'webmock/rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require './lib/mite-rb'

RSpec.configure do |config|
end
