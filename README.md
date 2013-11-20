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

Configure the source of the MODS XML in your model.  You can pass a string of XML to the mods_xml_source method, however it will also accept a block where you can call methods on self (so if the MODS XML string is held in MyClass#mods):

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
* ignore!
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

### Ignore!

In certain cases an application may need to explicitly remove a portion of the MODS metadata from the display (Contact being a prime example).  You can accomplish this by using the ignore! option.

    class MyController
      include ModsDisplay::ControllerExtension
      
      configure_mods_display do
        contact do
          ignore!
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

Note: Different MODS elements will have different default delimiters (mainly varying between a comma+space or a HTML line-break).

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

### Special Access Condition Configuration

The access condition statement is set to be ignored by default (same as ignore! configuration option).  If you would like the access condition statement to display you have to pass the access condition specific display! configuration option.

    configure_mods_display do
      access_condition do
        display!
      end
    end

## Usage

Once installed, the class that included the `ControllerExtension` (`MyController`) will have the `render_mods_display` method available.  This method takes one argument which is an instance of the class that included the `ModelExtension` (`MyClass`).

    render_mods_display(@model) # where @model.is_a?(MyClass)

The basic render call will return the top-level ModsDisplay::HTML class object.  Any String method (e.g. #html_safe) you call on this top-level object will be sent down to the #to_html method which will return the HTML for all the metadata in the MODS document.

    render_mods_display(@model).to_html

You can abstract the main (first) title by calling #title on the top-level HTML method

    render_mods_display(@model).title

When getting JUST the main (first) title out of the metadata, it will be useful to get the rest of the metadata without the main title.  You can accomplish this by calling #body on the top-level HTML object.

    render_mods_display(@model).body

## Advanced Usage

You can also access the array of ModsDisplay::Values objects for a given class directly by calling the name of the class. The class names are not always intuitive for public consumption so you may want to check the code the particular method to call.

    render_mods_display(@model).abstract
    => [#<ModsDisplay::Values @label="Abstract", @values=["Hey. I'm an abstract."]>]

Given that this semantics that we're concerned with here are more about titles and data construction rather than XML it may be required that you find something by the label. A common example of this is the imprint class.  The imprint class can retun other publication data that is not the imprint statement.  You'll want to select (using your favorite enumerable method) the element in the array that is an imprint.

    imprint = render_mods_display(@model).imprint.find do |data|
      data.label == "Imprint"
    end.values

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
