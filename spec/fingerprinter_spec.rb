require 'spec_helper'

module Fingerprintable
  class FingerprinterTestObject
    attr_accessor :foo,
                  :name,
                  :should_not_include_without_reader_method

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

  subject { described_class.new(object: obj1) }

  def fingerprinter(use_obj, **options)
    described_class.new(object: use_obj, **options)
  end

  def fingerprint(*args)
    fingerprinter(*args).fingerprint
  end

  def to_s(*args)
    fingerprinter(*args).to_s
  end

  it { expect(subject.attributes).to eq(%i[foo name]) }

  it 'fingerprints' do
    expected_fingerprint = '66b3c8638a457493a7dff5997040cc24'

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

    expected_fingerprint = '30ce8555029d32a50b61a4e6874954c3'

    expect(fingerprint(obj1)).to eq(expected_fingerprint)
    expect(fingerprint(obj1)).to eq(expected_fingerprint)

    obj2.foo = :new_val
    updated_finger_print = fingerprint(obj1)
    expect(updated_finger_print).not_to eq(expected_fingerprint)
    expect(updated_finger_print).to eq('1bcb687dddc01fa19f135d35be58f263')

    obj1.foo = '9.99'
    expect(fingerprint(obj1)).not_to eq(updated_finger_print)
    expect(fingerprint(obj1)).to eq('193bd801703350a46c9e90fbf5a1c7d6')
  end

  describe '#diff' do
    let(:f1) { described_class.new(object: obj1) }
    let(:f2) { described_class.new(object: obj2) }

    it { expect(f1).to be_diff(f2) }
    it { expect(f1.diff(f2).sort).to eq(%i[name]) }
  end

  describe '.diff' do
    let(:obj1) { Fingerprintable::FingerprinterTestObject.new(name: :name1) }
    let(:obj2) { Fingerprintable::FingerprinterTestObject.new(name: :name2) }

    it { expect(described_class.diff(obj1, obj2).sort).to eq(%i[name]) }
  end
end
