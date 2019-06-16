require 'spec_helper'

RSpec.describe Fingerprintable do
  it "has a version number" do
    expect(Fingerprintable::VERSION).not_to be nil
  end
end
