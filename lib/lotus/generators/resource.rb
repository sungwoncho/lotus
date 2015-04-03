require 'lotus/generators/abstract'
require 'lotus/utils/string'

module Lotus
  module Generators
    class Resource < Abstract

      SUFFIX = '.rb'.freeze

      def initialize(command)
        super

        cli.class.source_root(source)
      end

      def start
        opts = {
          resource_name: resource_name
        }

        templates = {
          'entity.rb.tt' => _entity_path,
          'repository.rb.tt' => _repository_path
        }

        templates.each do |src, dst|
          cli.template(source.join(src), target.join(dst), opts)
        end
      end

      def resource_name
        @resource_name ||= Utils::String.new(name).classify
      end

      private

      def _entity_path
        _entity_path_without_suffix.to_s + SUFFIX
      end

      def _repository_path
        _repository_path_without_suffix.to_s + SUFFIX
      end

      def _entity_path_without_suffix
        Pathname.new(["lib", app_name, "entities", name].join(File::SEPARATOR))
      end

      def _repository_path_without_suffix
        Pathname.new(["lib", app_name, "repositories", name].join(File::SEPARATOR))
      end
    end
  end
end
