# Capistrano::SharedConfig

This gem provides some capistrano tasks for config files management during deploy.
With it you can:

1. Create symlinks to config files in shared directory on each deploy
2. Upload config files to shared directory on each deploy
3. Use erb and capistrano tasks binding in your config files
4. Make separate config files for each rails environment

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-shared_config', github: 'Rakoth/capistrano-shared_config'
```

And then execute:
```
$ bundle
```

## Usage

Configure variables in config/deploy.rb, then require capistrano/shared_config:

```ruby
set :shared_config_files, %w[settings.local nginx.conf]
set :shared_config_symlinks, %w[database, settings.local newrelic.yml] # default is same as shared_config_files

require 'capistrano/shared_config'
```

Notice, you may skip `.yml` extension when configuring configs lists.

Make sure, you require capistrano/shared\_config after desired `shared_config_files` set

You can also configure, when to run provided tasks:

```ruby
set :run_shared_config_symlinks, [:before, 'deploy:assets:precompile'] # default is [:after, 'deploy:update_code']
set :run_shared_config_sync, [:before, 'deploy:assets:precompile'] # default is [:after, 'deploy:update_code']
set :run_early_shared_config_check, [:before, 'deploy'] # default is [:before, 'deploy:update_code']

require 'capistrano/shared_config'
```

## Config Files Lookup

For every file_name from `shared_config_files` (after adding default `.yml` if needed) it will lookup in several places:

1. config/rails\_env.file\_name.erb
2. config/rails\_env.file\_name
3. config/file\_name.erb
4. config/file\_name

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
