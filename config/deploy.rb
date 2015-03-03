# config valid only for Capistrano 3.1
#lock '3.2.0'

set :application, 'pretator'
set :repo_url, 'git@github.com:infovore/pretator.git'

set :deploy_via, :remote_cache

# files to exclude
set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules"]

set :keep_releases, 5

# set :format, :pretty

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
       execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :updated, :compile_assets

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

# rbenv stuff

set :rbenv_type, :system
set :rbenv_custom_path, '/usr/local/rbenv'
set :rbenv_ruby, '1.9.3-p547'

