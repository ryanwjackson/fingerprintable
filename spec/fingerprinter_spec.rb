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
    expected_fingerprint = '826f9904b35860b8301f87d7c0839e3e'

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

    expected_fingerprint = 'fe3c49aeb8d8debe3052a6c784ac6c49'

    expect(fingerprint(obj1)).to eq(expected_fingerprint)
    expect(fingerprint(obj1)).to eq(expected_fingerprint)

    obj2.foo = :new_val
    updated_finger_print = fingerprint(obj1)
    expect(updated_finger_print).not_to eq(expected_fingerprint)
    expect(updated_finger_print).to eq('e81ecc3016019e0d8ee6eb12e8f7bef3')

    obj1.foo = '9.99'
    expect(fingerprint(obj1)).not_to eq(updated_finger_print)
    expect(fingerprint(obj1)).to eq('2b79459a43745cc788fcfd33b38ec2fc')
  end

  describe '#diff' do
    let(:f1) { described_class.new(object: obj1) }
    let(:f2) { described_class.new(object: obj2) }

    it { expect(f1).to be_diff(f2) }
    it { expect(f1.diff(f2).sort).to eq(%i[@name]) }
  end

  describe '.diff' do
    let(:obj1) { Fingerprintable::FingerprinterTestObject.new(name: :name1) }
    let(:obj2) { Fingerprintable::FingerprinterTestObject.new(name: :name2) }

    it { expect(described_class.diff(obj1, obj2).sort).to eq(%i[@name]) }
  end
end
