# frozen_string_literal: true

module Fingerprintable
  class Fingerprinter
    attr_reader :attributes,
                :fallback_to_string,
                :ignore,
                :object

    def initialize(
      attributes: [],
      cache: {},
      fallback_to_string: false,
      ignore: [],
      object:
    )
      @fallback_to_string = fallback_to_string
      @ignore = ignore | ignore.map { |e| "@#{e}".to_sym }
      @object = object
      @attributes = populate_attributes(attributes: attributes, ignore: ignore)
      @cache = cache || {}
      @cache[object] = next_cache_id
      @fingerprinted = false
    end

    def cache
      fingerprint unless @fingerprinted
      @cache
    end

    def diff(other_fingerprinter)
      raise "Passed object (#{other_fingerprinter.class.name}) does not match the fingerprinter object class: #{object.class.name}" if object.class != other_fingerprinter.object.class

      values = object_values_hash
      other_values = other_fingerprinter.object_values_hash

      (attributes | other_fingerprinter.attributes).reject { |e| values[e] == other_values[e] }
    end

    def diff?(other_fingerprinter)
      diff(other_fingerprinter).any?
    end

    def deep_convert_and_sort(obj)
      case obj
      when nil
        ''
      when String
        obj.to_s
      when FalseClass, Float, Integer, Symbol, TrueClass
        obj.to_s
      when Array
        obj.map { |v| deep_convert_and_sort(v) }.sort.to_s
      when Hash
        Hash[obj.map { |k, v| [deep_convert_and_sort(k), deep_convert_and_sort(v)] }].sort.to_s
      when Module
        obj.name
      else
        fingerprint_object(obj)
      end
    end

    def fingerprint
      @fingerprint ||= begin
        @fingerprinted = true
        Digest::MD5.hexdigest(to_s)
      end
    end

    def object_values_hash
      @object_values_hash ||= Hash[attributes.map do |attr|
        [attr, object.send(attr)]
      end]
    end

    def to_s
      @to_s ||= deep_convert_and_sort(object_values_hash).to_s
    end

    def self.diff(obj1, obj2)
      f1 =  if obj1.respond_to?(:fingerprinter)
              obj1.fingerprinter
            else
              Fingerprinter.new(object: obj1)
            end

      f2 =  if obj2.respond_to?(:fingerprinter)
              obj2.fingerprinter
            else
              Fingerprinter.new(object: obj2)
            end

      f1.diff(f2)
    end

    private

    def fingerprint_object(use_object)
      return cache[use_object] if cache.include?(use_object)

      fingerprinter = if use_object.respond_to?(:fingerprint)
                        use_object.fingerprinter(cache: @cache)
                      elsif use_object.respond_to?(:instance_variables)
                        Fingerprinter.new(cache: cache, object: use_object)
                      end

      if fingerprinter.nil?
        raise "Do not know how to fingerprint #{use_object.class.name}.  Did you mean to add Fingerprintable to this object?" unless fallback_to_string
        raise "#{use_object.class.name} does not respond to to_s.  Did you mean to add Fingerprintable to this object?" unless use_object.respond_to?(:to_s)

        use_object.to_s
      end

      ret = fingerprinter.fingerprint
      cache.merge!(fingerprinter.cache)
      ret
    end

    def next_cache_id
      @cache.count
    end

    def populate_attributes(attributes:, ignore:)
      instance_variables = Hash[object.instance_variables.map { |e| [e, 1] }]
      ret = object.class.instance_methods.select do |method|
        instance_variables.key?("@#{method}".to_sym)
      end
      ret |= attributes
      ret -= ignore
      ret.map(&:to_sym).sort
    end
  end
end
