require 'yaml'
require 'erb'

module Capistrano
  module SharedConfig
    class ConfigFile
      def initialize name, capistrano_binding
        @name = self.class.name(name)
        @capistrano_binding = capistrano_binding
      end

      attr_reader :name, :capistrano_binding, :error

      def env
        @env ||= eval('rails_env', capistrano_binding)
      end

      def self.name name
        name += '.yml' unless name =~ /\.(yml|conf|rb)$/
        name
      end

      def location
        @location ||= [
          File.join('.', 'config', [env, name, 'erb'].join(?.)),
          File.join('.', 'config', [env, name].join(?.)),
          File.join('.', 'config', [name, 'erb'].join(?.)),
          File.join('.', 'config', name)
        ].detect(&File.method(:exists?))
      end

      def content
        @content ||= ERB.new(File.read(location)).result(capistrano_binding)
      end

      def valid?
        begin
          case name
          when /\.yml$/
            YAML.load content
          when /\.rb$/
            eval("BEGIN {return true}\n#{content}", nil, name, 0)
          else
            # hope it is valid
          end

          true
        rescue Exception => exception
          @error = "Error in config file: #{exception.inspect}\n#{exception.message}"
          false
        end
      end
    end
  end
end
