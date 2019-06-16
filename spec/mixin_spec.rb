require 'spec_helper'

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

RSpec.describe Fingerprintable::Mixin do
  let(:klass) { Fingerprintable::MixinTestObject }
  let(:obj) { klass.new }
  let(:fingerprinter) { obj.fingerprinter }

  it do
    expect(fingerprinter.attributes.sort).to eq(%i[asdf baz foo])
  end
end
