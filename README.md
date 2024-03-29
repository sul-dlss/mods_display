# ModsDisplay

A gem for displaying MODS Metadata in a configurable way.  

This gem is used to centralize the display logic of MODS metadata by creating html fragments such as

```
   <dt>Publisher</dt>
   <dd>Diagon Alley Publications</dd>
```

which can be styled in consuming apps such as SearchWorks or Exhibits.

## Demo

You can experiment with the output of the latest release of the gem in the [demo app](http://mods-display.herokuapp.com/).

## Installation

Add this line to your application's Gemfile:

    gem 'mods_display'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mods_display

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
