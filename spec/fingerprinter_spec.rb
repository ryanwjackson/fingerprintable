require 'spec_helper'

module Fingerprintable
  class FingerprinterTestObject
    attr_accessor :foo, :name

    def initialize(foo: nil, name:)
      self.foo = foo
      self.name = name
    end
  end
end

RSpec.describe Fingerprintable::Fingerprinter do
  let(:obj1) { Fingerprintable::FingerprinterTestObject.new(name: :obj1) }
  let(:obj2) { Fingerprintable::FingerprinterTestObject.new(name: :obj2) }
  let(:obj3) { Fingerprintable::FingerprinterTestObject.new(name: :obj3) }

  subject { described_class.new(object: obj) }

  def fingerprinter(use_obj, **options)
    described_class.new(object: use_obj, **options)
  end

  def fingerprint(*args)
    fingerprinter(*args).fingerprint
  end

  def to_s(*args)
    fingerprinter(*args).to_s
  end

  it 'fingerprints' do
    expected_fingerprint = '4d5eb5f16602766f3178a98be2c770f0'

    expect(fingerprint(obj1)).to eq(expected_fingerprint)
    expect(fingerprint(obj1)).to eq(expected_fingerprint)
  end

  it 'handles cycles' do
    obj1.foo = obj2
    obj2.foo = obj1

    expect(fingerprint(obj1)).not_to eq(fingerprint(obj2))
  end

  it do
    obj1.foo = obj2
    obj2.foo = obj3
    obj3.foo = obj1

    expected_fingerprint = '422cbf9f3e82a153aff21db35d6d8481'

    expect(fingerprint(obj1)).to eq(expected_fingerprint)
    expect(fingerprint(obj1)).to eq(expected_fingerprint)

    obj2.foo = :new_val
    updated_finger_print = fingerprint(obj1)
    expect(updated_finger_print).not_to eq(expected_fingerprint)
    expect(updated_finger_print).to eq('6a47e51afe405c51237d86b7f3b755e4')

    obj1.foo = '9.99'
    expect(fingerprint(obj1)).not_to eq(updated_finger_print)
    expect(fingerprint(obj1)).to eq('3687f7efae58f37ff365e11dae58cd6d')
  end
end
