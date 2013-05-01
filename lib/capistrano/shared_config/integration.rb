require 'capistrano'
require 'capistrano/version'
require 'capistrano/shared_config/config_file'

module Capistrano
  module SharedConfig
    class Integration
      def self.load_into(capistrano_config)
        capistrano_config.load do
          set(:shared_config_files, fetch(:shared_config_files, []))
          set(:shared_config_symlinks, fetch(:shared_config_symlinks, shared_config_files))

          set(:run_shared_config_symlinks, fetch(:run_shared_config_symlinks, [:after, 'deploy:update_code']))
          set(:run_shared_config_sync, fetch(:run_shared_config_sync, [:after, 'deploy:update_code']))
          set(:run_early_shared_config_check, fetch(:run_early_shared_config_check, [:before, 'deploy:update_code']))

          set(:_shared_config_files, (ENV['FILE'] ? [ENV['FILE']] : shared_config_files).
            map{|name| ConfigFile.new(name, binding)}
          )

          namespace :shared_config do
            desc 'Create shared config folder'
            task :setup, roles: [:app, :db] do
              run "mkdir #{File.join(shared_path, 'config')}"
            end
            after 'deploy:setup', 'shared_config:setup'

            desc 'Create symlinks for config files from shared_config_symlinks array'
            task :symlinks, roles: [:app, :db] do
              next if shared_config_symlinks.empty?
              commands = shared_config_symlinks.map do |name|
                full_name = ConfigFile.name(name)
                "ln -nfs #{File.join(shared_path, 'config', full_name)} #{File.join(latest_release, 'config', full_name)}"
              end

              run commands.join(' && ')
            end
            on run_shared_config_symlinks.first, 'shared_config:symlinks', only: run_shared_config_symlinks.last

            desc 'Sync all config files'
            task :sync, roles: [:app, :db] do
              _shared_config_files.each do |file|
                put(file.content, File.join(shared_path, 'config', file.name))
              end
            end
            on run_shared_config_sync.first, 'shared_config:sync', only: run_shared_config_sync.last

            desc 'Check all config files'
            task :check, roles: [:app, :db] do
              _shared_config_files.each do |file|
                raise Capistrano::CommandError.new(file.error) unless file.valid?
              end
            end
            on run_early_shared_config_check.first, 'shared_config:check', only: run_early_shared_config_check.last
            before 'shared_config:sync', 'shared_config:check'

            task :show do
              puts shared_config_files.inspect
              puts shared_config_symlinks.inspect
              puts _shared_config_files.inspect
              _shared_config_files.each do |file|
                puts file.name
                puts ?= * 80
                puts file.content
                puts ?= * 80
              end
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::SharedConfig::Integration.load_into(Capistrano::Configuration.instance)
end
