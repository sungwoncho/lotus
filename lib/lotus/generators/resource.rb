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
          resource_class: resource_class
        }

        templates = {
          'entity.rb.tt' => _entity_path,
          'repository.rb.tt' => _repository_path
        }

        generate_route

        templates.each do |src, dst|
          cli.template(source.join(src), target.join(dst), opts)
        end
      end

      def resource_class
        @resource_class ||= Utils::String.new(name).classify
      end

      private

      def generate_route
        path = target.join(_routes_path)
        path.dirname.mkpath

        FileUtils.touch(path)

        cli.insert_into_file _routes_path, before: /\A(.*)/ do
          "get '/#{name}', to: '#{name}#index'
get '/#{name}/:id', to: '#{name}#show'
get '/#{name}/new', to: '#{name}#new'
post '/#{name}', to: '#{name}#create'
get '/#{name}/:id/edit', to: '#{name}#edit'
patch '/#{name}/:id', to: '#{name}#update'
delete '/#{name}/:id', to: '#{name}#destroy'
"
        end
      end

      def _routes_path
        app_root.join("config", "routes#{ SUFFIX }")
      end

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
