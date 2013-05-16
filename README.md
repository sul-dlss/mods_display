[![Build Status](https://travis-ci.org/sul-dlss/mods_display.png?branch=master)](https://travis-ci.org/sul-dlss/mods_display)

# ModsDisplay

A gem for displaying MODS Metadata in a configurable way.

## Installation

Add this line to your application's Gemfile:

    gem 'mods_display'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mods_display
    
Include the `ModelExtension` into your model.

    class MyClass
      include ModsDisplay::ModelExtension
    end

Configure the source of the MODS xml string

    class MyClass
      ....
      
      mods_xml_source do |model|
        model.mods
      end
      
    end

Include the `ControllerExtension` into your rails controller (or another class if not using rails).

    class MyController
      include ModsDisplay::ControllerExtension
    end
    
Optionally configure the mods display gem (more on configuration later).

    class MyController
      ....
      configure_mods_display do
        ....
      end
    end

## Usage

Once installed, the class that included the `ControllerExtension` (`MyController`) will have the `render_mods_display` method available.  This method takes one argument which is an instance of the class that included the `ModelExtension` (`MyClass`).

    render_mods_display(@model) # where @model.is_a?(MyClass)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
