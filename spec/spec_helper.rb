require_relative '../lib/mq_reader'

require 'minitest/autorun'
require 'webmock/rspec'
require 'cgi'
WebMock.disable_net_connect!

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

YOUR_API_KEY = "Fmjtd%7Cluur2g61nl%2Cbl%3Do5-9az25f"

def stub_get_geocode_with(fixture)
  stub_request(:get, "http://open.mapquestapi.com/geocoding/v1/address?key=#{CGI.unescape(YOUR_API_KEY)}&location=2710%20Avenida%208%20de%20Octubre,%20Montevideo,%20Uruguay&maxResults=2").to_return(:status => 200, :body => fixture(fixture))
end
