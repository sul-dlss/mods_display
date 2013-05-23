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

## Configuration

In the class that you include the `ModsDisplay::ControllerExtension` you can configure various behavior for different fields.  The configuration options provided by `ModsDisplay::Configuration::Base` are:

* label_class
* value_class
* delimiter
* link

### Label and Value classes

Both label_ and value_class accept strings to put in as a class.

    class MyController
      include ModsDisplay::ControllerExtension
      
      configure_mods_display do
        title do
          label_class "title-label"
          value_class "title-value"
        end
      end
    end

### Delimiter

The delimiter configuration option accepts a string which will be used to delimit multiple multiple values within a single label.

    configure_mods_display do
      note do
        delimiter "<br/>"
      end
    end

Note: The default is a comma and a space (", ")

### Link

The link configuration option takes 2 parameters. The first is a key that is a method_name available in the class including `ModsDisplay::ControllerExtension` and the 2nd is options to pass to that method.  This method must return a string that will be used as the href attribute of the link. (NOTE: If you have the %value% token in your options that will be replaced with the value of the field being linked)

    class MyController
      include ModsDisplay::ControllerExtension
      
      configure_mods_display do
        format do
          link :format_path, '"%value%"'
        end
      end
      
      def format_path(format)
        "http://example.com/?f[format_field][]=#{format}"
      end
    end

### Special Subject Configuration

Depending on the implementation of subjects there may be different ways you would want to link them.  The standard way of linking will just create a link passing the value to the href and the link text.  However; in certain cases the subjects should be linked so that each subject to the right of a delimiter should have the values of all its preceding values in the href.

    [Country](http://example.com/?"Country") > [State](http://example.com/?"Country State") > [City](http://example.com/?"Country State City")
    
This can be accomplished by setting the hierarchical_link configuration option to true for subjects

    configure_mods_display do
      subject do
        hierarchical_link true
      end
    end

NOTE: The default delimiter is set to > for subjects.

## Usage

Once installed, the class that included the `ControllerExtension` (`MyController`) will have the `render_mods_display` method available.  This method takes one argument which is an instance of the class that included the `ModelExtension` (`MyClass`).

    render_mods_display(@model) # where @model.is_a?(MyClass)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
