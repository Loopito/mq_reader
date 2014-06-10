# MQReader

MQReader helps you make calls to the mapquest open geocoding api.

It's meant to be simple and easy to use.

## Contents

<ul>
  <li><a href="#overview">Overview</a></li>
  <li><a href="#installation">Installation</a></li>
  <li><a href="#usage">Usage</a>
  <li><a href="#contributing">Contributing</a></li>
</ul>

<a name="overview">
## Overview

Using MQReader, you can:

Easily Geocode addresses using the MapQuest open geocoding api.
It's meant to be as simple as possible. For those cases when you just want to geocode an address.

<a name="installation">
## Installation

Add 'mq_reader' to your Gemfile, then 'bundle'

```ruby
gem 'mq_reader'
```

<a name="usage">
## Usage

You first need to configure your MapQuest api key. You can get one at their website.
Once you have it, you can configure it wherever you want like this:

```ruby
MQReader.configure do |config|
  config.api_key = YOUR_API_KEY
end
```

Now it's ready to be used!

Just do:

```ruby
geocode = MQReader.geocode_address("2710 Avenida 8 de Octubre, Montevideo, Uruguay")
```

And you'll have a MQGeocode object from which you can get every detail of the geocode.

```ruby
geocode.street
  #=> "Avenida 8 de Octubre 2710"
geocode.lat
  #=> -34.889265
geocode.lng
  #=> -56.15989
```

MQReader generates accesor methods for everything that comes with the response.
You can check the MapQuest api to see what other values come with the response.
Lets say you want the value of geocodeQualityCode.
You just do:

```ruby
geocode.geocode_quality_code
  #=> "P1XXX"
```

...and when in the future the response geocoded address comes with a aNewThingResponded attribute.
The accesor will already be generated. You can do:

```ruby
geocode.a_new_thing_responded
  #=> value of aNewThingResponded attribute in the response.
```


You can also add more params to the geocode request with an options hash:

```ruby
geocode = MQReader.geocode_address("2710 Avenida 8 de Octubre, Montevideo, Uruguay", {max_results: 2})
```

Params can be written in ruby sintax(snake case).

<a name="contributing">
## Contributing

Feel free to contribute or make suggestions!
