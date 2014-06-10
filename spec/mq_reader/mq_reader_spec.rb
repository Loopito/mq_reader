require_relative '../spec_helper'
describe MQReader do

  before(:each) do
    MQReader.configure do |config|
      config.api_key = YOUR_API_KEY
    end
  end

  describe 'ClassMethods' do

    before do
      stub_get_geocode_with('address_found.json')
    end

    describe '#geocode_address' do
      context 'address found' do
        it 'should return MQGeocode object with attributes' do
          geocode_obj = MQReader.geocode_address("2710 Avenida 8 de Octubre, Montevideo, Uruguay", { max_results: 2 })
          expect(geocode_obj.class).to eq(MQReader::MQGeocode)
          expect(geocode_obj.lat).to eq(-34.889265)
          expect(geocode_obj.lng).to eq(-56.15989)
          expect(geocode_obj.street).to eq('Avenida 8 de Octubre 2710')
          expect(geocode_obj.geocode_quality).to eq('POINT')
          expect(geocode_obj.country).to eq('UY')
          expect(geocode_obj.geocode_quality_code).to eq('P1XXX')
          expect(geocode_obj.address_found?).to be_true
        end
      end
      context 'address not found' do
        it 'should return MQGeocode object with no attributes except raw_geocode' do
          stub_get_geocode_with('address_not_found.json')
          geocode_obj = MQReader.geocode_address("2710 Avenida 8 de Octubre, Montevideo, Uruguay", { max_results: 2 })
          expect(geocode_obj.class).to eq(MQReader::MQGeocode)
          expect(geocode_obj.street).to be_nil
          expect(geocode_obj.address_found?).to be_false
        end
      end
      it 'should call #geocode_address on BaseClass' do
        MQReader::BaseClass.should_receive(:geocode_address)
        MQReader.geocode_address('home', max_results: 2)
      end
      it "should call #send_get_to_mapquest with correct params and MQGeocode#new" do
        MQReader::BaseClass.should_receive(:send_get_to_mapquest).with(MQReader::GEOCODING_PATH, { location: 'home', 'maxResults' => 2 })
        MQReader::MQGeocode.should_receive(:new)
        MQReader.geocode_address('home', max_results: 2)
      end
    end

    describe '#send_get_to_mapquest' do
      it 'should call #get on BaseClass, and the call #body on the result of #get' do
        obj = double('object')
        MQReader::BaseClass.should_receive(:get).with(MQReader::BASE_URI + 'path', { query: { key: MQReader.configuration.api_key, param: 'something' } }).and_return(obj)
        obj.should_receive(:body)
        MQReader::BaseClass.send(:send_get_to_mapquest, 'path', { param: 'something' })
      end
    end

    describe '#to_mapquest_notation' do
      it 'should transform keys' do
        expect(MQReader::BaseClass.send(:to_mapquest_notation, ({}))).to eq({})
        expect(MQReader::BaseClass.send(:to_mapquest_notation, ({a_key: 'value', another_key: 'value'}))).to eq({'aKey' => 'value', 'anotherKey' => 'value'})
        expect(MQReader::BaseClass.send(:to_mapquest_notation, ({'' => 'value'}))).to eq({'' => 'value'})
        expect(MQReader::BaseClass.send(:to_mapquest_notation, ({a_key: 'value'}))).to eq({'aKey' => 'value'})
      end
    end

  end

  describe 'UtilMethods' do
    describe 'camelize_string' do
      it 'should camelize string and leave the first character lowercase' do
        expect(MQReader::BaseClass.camelize_string('')).to eq('')
        expect(MQReader::BaseClass.camelize_string('a_long_string')).to eq('aLongString')
      end
    end
  end

  describe 'configuration' do
    it 'should be possible to set api_key and retrieve it' do
      MQReader.configure do |config|
        config.api_key = "1234567"
      end
      expect(MQReader.configuration.api_key).to eq("1234567")
    end
  end

  describe 'MQGeocode class' do

    let(:obj) { MQReader::MQGeocode.new("{\"results\":[{\"locations\":[{\"latLng\":{\"lng\":-56.15989,\"lat\":-34.889265},\"adminArea4\":\"\",\"adminArea5Type\":\"City\",\"adminArea4Type\":\"County\",\"adminArea5\":\"Montevideo\",\"street\":\"Avenida 8 de Octubre 2710\",\"adminArea1\":\"UY\",\"adminArea3\":\"Montevideo\",\"type\":\"s\",\"displayLatLng\":{\"lng\":-56.15989,\"lat\":-34.889265},\"linkId\":0,\"postalCode\":\"11600\",\"sideOfStreet\":\"N\",\"dragPoint\":false,\"adminArea1Type\":\"Country\",\"geocodeQuality\":\"POINT\",\"geocodeQualityCode\":\"P1XXX\",\"mapUrl\":\"http://open.mapquestapi.com/staticmap/v4/getmap?key=Fmjtd|luur2g61nl,bl=o5-9az25f&type=map&size=225,160&pois=purple-1,-34.8892649,-56.1598895,0,0|&center=-34.8892649,-56.1598895&zoom=15&rand=1680921967\",\"adminArea3Type\":\"State\"}],\"providedLocation\":{\"location\":\"2710 Avenida 8 de Octubre, Montevideo, Uruguay\"}}],\"options\":{\"ignoreLatLngInput\":false,\"maxResults\":2,\"thumbMaps\":true},\"info\":{\"copyright\":{\"text\":\"© 2014 MapQuest, Inc.\",\"imageUrl\":\"http://api.mqcdn.com/res/mqlogo.gif\",\"imageAltText\":\"© 2014 MapQuest, Inc.\"},\"statuscode\":0,\"messages\":[]}}") }

    describe 'intialization' do
      context 'request with errors' do
        it 'should raise an error' do
          expect{MQReader::MQGeocode.new("{\"info\":{\"statuscode\":1,\"messages\":[\"The request failed.\"]}}")}.to raise_error(StandardError)
        end
      end

      context 'request with no errors' do
        it 'should have methods to access the geocode values' do
          expect(obj.street).to eq('Avenida 8 de Octubre 2710')
          expect(obj.geocode_quality).to eq('POINT')
          expect(obj.address_found?).to be_true
        end
        it 'should have methods to access the variables that are not defined in the class. Via method_missing' do
          expect(obj.street).to eq('Avenida 8 de Octubre 2710')
          expect(obj.geocode_quality_code).to eq('P1XXX')
          expect(obj.side_of_street).to eq('N')
        end
      end
    end

    describe 'address_found?' do
      context 'address found' do
        it 'should return true' do
          expect(obj.address_found?).to be_true
        end
      end
      context 'address not found' do
        it 'should return false' do
          expect(MQReader::MQGeocode.new("{\"results\":[{\"locations\":[]}], \"info\":{\"statuscode\":0}}").address_found?).to be_false
        end
      end
    end
  end
end