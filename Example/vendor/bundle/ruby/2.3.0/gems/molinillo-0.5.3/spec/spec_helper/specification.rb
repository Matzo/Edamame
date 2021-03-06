# frozen_string_literal: true
module Molinillo
  class TestSpecification
    attr_accessor :name, :version, :dependencies
    def initialize(hash)
      self.name = hash['name']
      self.version = VersionKit::Version.new(hash['version'])
      self.dependencies = hash['dependencies'].map do |(name, requirement)|
        VersionKit::Dependency.new(name, requirement.split(',').map(&:chomp))
      end
    end

    def ==(other)
      name == other.name &&
        version == other.version &&
        dependencies == other.dependencies
    end

    def to_s
      "#{name} (#{version})"
    end

    def inspect
      "#<#{self.class} name=#{name} version=#{version} dependencies=[#{dependencies.join(', ')}]>"
    end
  end
end
