module Fingerprintable
  module Mixin
    module ClassMethods
      def inherited(subclass)
        subclass.fingerprint(*fingerprintable_attributes)
        super(subclass)
      end

      def fingerprint(*attrs, ignore: [])
        @fingerprintable_attributes = fingerprintable_attributes | attrs
        ignore = [ignore] if ignore.is_a?(String) || ignore.is_a?(Symbol)
        fingerprintable_config[:ignore] |= ignore
      end

      def fingerprintable_attributes
        @fingerprintable_attributes ||= []
      end

      def fingerprintable_config
        @fingerprintable_config ||= {
          ignore: []
        }
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def fingerprint(*args)
      fingerprinter.fingerprint(*args)
    end

    def fingerprinter(*attrs, cache: {})
      Fingerprinter.new(
        attributes: self.class.fingerprintable_attributes | attrs,
        cache: cache,
        object: self,
        **self.class.fingerprintable_config
      )
    end
  end
end