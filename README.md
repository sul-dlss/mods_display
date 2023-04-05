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
