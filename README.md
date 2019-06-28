# Fingerprintable

[![Build Status](https://travis-ci.org/ryanwjackson/fingerprintable.svg?branch=master)](https://travis-ci.org/ryanwjackson/fingerprintable) [![Coverage Status](https://coveralls.io/repos/github/ryanwjackson/fingerprintable/badge.svg?branch=master)](https://coveralls.io/github/ryanwjackson/fingerprintable?branch=master)

Fingerprintable is an easy way to fingerprint any object in Ruby.  It handles cycles and allows you to override what attributes you want to include in the fingerprint.

By default, Fingerprintable will use all instance variables of an object.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fingerprintable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fingerprintable

## Usage

You can call `Fingerprintable::Fingerprinter` directly, or you can add `Fingerprintable::Mixin` to any class like so:

```ruby
module Fingerprintable
  class MixinTestObject
    include Fingerprintable::Mixin

    attr_accessor :foo, :bar

    fingerprint :baz,
                ignore: :bar

    fingerprint :asdf

    def initialize(foo = nil)
      self.foo = foo
    end
  end
end
```

This results in a fingerprint being generated for these attributes: `[:@foo, :asdf, :baz]`

To get a fingerprint of any instance, just call `.fingerprint`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanwjackson/fingerprintable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fingerprintable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ryanwjackson/fingerprintable/blob/master/CODE_OF_CONDUCT.md).
