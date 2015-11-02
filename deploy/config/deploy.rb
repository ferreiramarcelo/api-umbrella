require "dotenv"
Dotenv.load

# config valid only for current version of Capistrano
lock "3.4.0"

set :application, "api-umbrella"
set :repo_url, "https://github.com/NREL/api-umbrella.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/api-umbrella/embedded/apps/core"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push("config/database.yml", "config/secrets.yml")

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
  "build/work",
  "src/api-umbrella/web-app/public/web-assets",
  "src/api-umbrella/web-app/tmp",
  "vendor"
)

# Default value for default_env is {}
set :default_env, fetch(:default_env, {}).merge({
  "PATH" => "/opt/api-umbrella/bin:/opt/api-umbrella/embedded/bin:$PATH",

  # Reset Ruby related environment variables. This is in case the system being
  # deployed to has something like rvm/rbenv/chruby in place. This ensures that
  # we're using our API Umbrella bundled version of Ruby on PATH rather than
  # another version.
  "GEM_PATH" => "/opt/api-umbrella/embedded/lib/ruby/gems/*",
  "RUBY_ROOT" => "",
  "RUBYLIB" => "",

  # The real secret tokens are read from the api-umbrella config file when the
  # web app is started. But for rake task purposes (like asset precompilation
  # where these don't matter), just set some dummy values during deploy.
  "RAILS_SECRET_TOKEN" => "TEMP",
  "DEVISE_SECRET_KEY" => "TEMP",
})

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  # The ember-rails gem's handling of temp files isn't ideal when multiple users
  # might touch the files. So for now, just make these temp files globally
  # writable. See:
  # https://github.com/emberjs/ember-rails/issues/315#issuecomment-47703370
  # https://github.com/emberjs/ember-rails/pull/357
  task :ember_permissions do
    on roles(:app) do
      execute "mkdir -p #{release_path}/src/api-umbrella/web-app/tmp/ember-rails && chmod -R 777 #{release_path}/src/api-umbrella/web-app/tmp/ember-rails"
    end
  end
  after :updated, :ember_permissions

  desc "Reload application"
  task :reload do
    on roles(:app), :in => :sequence, :wait => 5 do
      execute :sudo, "api-umbrella reload"
    end
  end
  after :publishing, :reload
end
