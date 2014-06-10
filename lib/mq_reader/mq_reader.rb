module MQReader

  BASE_URI = 'http://open.mapquestapi.com'
  GEOCODING_PATH = '/geocoding/v1/address'

  module ClassMethods

    @options = []

    # Geocode a address.
    # This method takes an address as a string and performs the geocoding against mapquest's api.
    # The options hash can have any option accepted by the mapquest geocoding api.
    # The options key can be written ruby-style with underscores, they are transformed to mapquests format.
    # If in the future a new option is added to the api by mapquest, you can add it in the options hash and it will work.
    #
    # @param [String] address to geocode
    # @param [Hash] options for mapquest geocoding service
    def geocode_address(address, options = {})
      path = GEOCODING_PATH
      params = ({ location: CGI::escape(address) }.merge!(to_mapquest_notation(options) ))
      MQGeocode.new(send_get_to_mapquest(path, params))
    end

    private

    # Method that posts to the mapquest geocoding api
    #
    # @params [String] path to the geocoding api. /geocoding/v1..
    # @params [Hash] params to be sent with the request. See http://open.mapquestapi.com/geocoding/ for params details.
    #
    # @return [String] with geocoding response body.
    def send_get_to_mapquest(path, params)
      self.get(BASE_URI + path, query: { key: MQReader.configuration.api_key}.merge!(params)).body
    end

    # Turns underscore keys into mapquest's camelized keys
    # I belive a good ruby api wrapper should let the developer write in a rubyish way.
    # Mapquest accepts options that are camelcased and start with a lowercase letter.
    #
    # @param [Hash] options to turn into mapquest's key format
    #
    # @return [Hash] options hash with mapquest's key format
    def to_mapquest_notation(options)
      Hash[options.map{ |k, v| [camelize_string(k.to_s), v] }]
    end
  end

  module UtilMethods
    # Same as camelize(:lower) in ActiveSupport
    #
    # @param [String] string to be camelized
    #
    # @return [String] camelized string
    #
    # Example
    # camelize_string("a_long_string") # => "aLongString"
    def camelize_string(string)
      string.split("_").each_with_index {|s, i| s.capitalize! unless i == 0 }.join("")
    end
  end

  #Extend the module on inclusion.
  #Include Httparty and prevent encoding the api_key(Already encoded by mapquest).
  def self.included(base)
    base.extend ClassMethods
    base.extend UtilMethods
    base.send :include, HTTParty
    # Avoid encoding the api key
    base.query_string_normalizer proc { |query|
      query.map do |key, value|
          "#{key}=#{value}"
      end.join('&')
    }
  end

  # Configuration Class
  # Right now it's only used to set the API key from the application that's using the gem.
  class Configuration
    attr_accessor :api_key
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  # Class used to be able to call #geocode_address directly.
  class BaseClass
    include MQReader
  end

  def self.geocode_address(*args)
    BaseClass.geocode_address(*args)
  end

  # Class to handle the response from the mapquest api
  #
  # Provides methods to get every value from the geocoded address.
  class MQGeocode
    attr_reader :street, :city, :zip, :county, :state, :country, :lat, :lng, :raw_geocode

    def initialize(json_geocode)
      @raw_geocode = JSON.parse(json_geocode)
      raise StandardError, "The request raised an error: #{@raw_geocode['info']['messages']}" if @raw_geocode['info']['statuscode'] != 0
      return if @raw_geocode['results'].first['locations'].empty?
      @lng,@lat = lat_lng_values
      @street = value('street')
      @city = value('adminArea5')
      @county = value('adminArea4')
      @state = value('adminArea3')
      @country = value('adminArea1')
      @zip = value('postalCode')
      @type = value('type')
      @geocode_quality = value('geocodeQuality')
      @side_of_street = value('sideOfStreet')
    end

    def address_found?
      @raw_geocode['results'].first['locations'].any?
    end

  private

    # Get the value of a field from the respond
    def value(field)
      @raw_geocode['results'].first['locations'].first[field]
    end

    # Get the latitude and longitude from the response
    def lat_lng_values
      latLng = value('latLng')
      return [latLng['lng'],latLng['lat']]
    end

    # Use method_missing to define accesors for any response attributes that might not be listed in #initialize
    # This accesors are rubyish(underscore notation).
    def method_missing(method_sym, *arguments, &block)
      result = send(:value, BaseClass.camelize_string(method_sym.to_s))
      result.empty? ? super : result
    end
  end
end