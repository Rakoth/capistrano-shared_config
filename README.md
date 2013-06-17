# Capistrano::SharedConfig

This gem provides some capistrano tasks for config files management during deploy.
With it you can:

* Create symlinks to config files in shared directory on each deploy
* Upload config files to shared directory from local machine on each deploy
* Use erb and capistrano tasks binding in your config files (it will compile before uploading to server)
* Make separate config files for each rails environment
* Automatically create shared_path/config directory on deploy:setup

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-shared_config'
```

And then execute:
```
$ bundle install
```

## Usage

Configure variables in config/deploy.rb, then require capistrano/shared_config:

```ruby
set :shared_config_files, %w[settings.local nginx.conf]
set :shared_config_symlinks, %w[database, settings.local newrelic.yml] # default is same as shared_config_files

require 'capistrano/shared_config'
```

Notice, you may skip `.yml` extension when configuring configs lists (Known extensions are: `.rb`, `.conf` and `.yml`).

Make sure, you require capistrano/shared\_config after desired `shared_config_files` set

You can also configure, when to run provided tasks:

```ruby
# set :run_shared_config_symlinks, [:after, 'deploy:update_code']
# set :run_shared_config_sync, [:after, 'deploy:update_code']
# set :run_early_shared_config_check, [:before, 'deploy:update_code']

require 'capistrano/shared_config'
```

## Advanced Usage

You can call particular cap task with FILE env variable specified to upload or check only one file:
```bash
$ cap shared_config:sync FILE=newrelic
```

Or you can inspect content generated in config file with `show` task like this:
```bash
$ cap shared_config:show FILE=settings.local
```
It will output content of specified file surrounded by `=====` lines

## Config Files Lookup

For uploading to server, provided task `sync` use files from `config` directory.
For every file_name in `shared_config_files` (after adding default `.yml` if needed)
it try to find the following files in order:

1. `config/rails_env.file_name.erb`
2. `config/rails_env.file_name`
3. `config/file_name.erb`
4. `config/file_name`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
