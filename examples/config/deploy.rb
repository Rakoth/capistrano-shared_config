set :application, 'app.example.com'

# Used in settings.local.yml. Usefull if you have many staging servers with same rails env.
set :redis_db, 5

# This files will be compiled from local template files and upload to shared folder on server on each deploy.
set :shared_config_files, %w[nginx.conf settings.local]

# For this files symlinks to shared folder will be created on each deploy.
set :shared_config_symlinks, %w[database settings.local]

# Change shared_config:symlinks tack position in deploy.
set :run_shared_config_symlinks, [:before, 'deploy:assets:precompile']

# Put require after configuring shared_config_* and run_shared_config_* variables.
require 'capistrano/shared_config'
