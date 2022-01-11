[![Build Status](https://travis-ci.org/sul-dlss/mods_display.png?branch=master)](https://travis-ci.org/sul-dlss/mods_display)

# ModsDisplay

A gem for displaying MODS Metadata in a configurable way.

## Demo

You can experiment with the output of the latest release of the gem in the [demo app](http://mods-display.herokuapp.com/).

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
    => [#<ModsDisplay::Values @label="Abstract:", @values=["Hey. I'm an abstract."]>]

Given that this semantics that we're concerned with here are more about titles and data construction rather than XML it may be required that you find something by the label. A common example of this is the imprint class.  The imprint class can return other publication data that is not the imprint statement.  You'll want to select (using your favorite enumerable method) the element in the array that is an imprint.

    imprint = render_mods_display(@model).imprint.find do |data|
      data.label == "Imprint:"
    end.values

## Release/Upgrade Notes

#### v0.5.0
There are three major changes in this version.

1. RelatedItem nodes with a type of `constituent` or `host` are now treated separately and will render the full MODS display of any nested metadata.  If accessing the `ModsDisplay::Values` directly through their accessors (e.g. custom grouping), this new metadata is available under `.nested_related_items`.
    * _**Note:** You may want to style and add some javascript toggling behavior (see exhibits for an example)._
2. Name nodes are now grouped/labeled by their role.  If you were iterating over the names and splitting them out by their labels, that will need to change.
3. Table of contents/Summaries are now split on `--` and rendered as an unordered list.
    * _**Note:** You may want to style this list._

#### v0.3.0

Labels now have internationalization support.  We have added colons to the english labels due to certain languages' punctuation rules requiring different spacing between the label and colon.

Given that fact, you will want to update any pre 0.3.0 code that searches for elements by label in a way that would fail with the presence of a colon.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
