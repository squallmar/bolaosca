require "bundler/capistrano"

# set :rvm_ruby_string, '2.0.0-p247'
# set :rvm_type, :user  # Don't use system-wide RVM

server "IP TO DEPLOY", :web, :app, :db, primary: true

set :default_environment, {
  "PATH" => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH",
  "RAILS_ENV" => "production"
}
set :rbenv_ruby, "1.9.3-p125"

set :normalize_asset_timestamps, false

set :application, "bolaosca"
set :user, "user_name"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "exemplo: git@bitbucket.org:repository/bolaosca.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true


before "deploy:cold", "deploy:install_bundler"

after "deploy", "deploy:cleanup", "deploy:precompile_assets"

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: { no_release: true } do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :seed do
    run "cd #{latest_release}; bundle exec rake db:seed"
  end

  task :precompile_assets do
    run "cd #{latest_release}; bundle exec rake assets:precompile"
  end

  task :install_bundler, roles: :app do
    run "type -P bundle &>/dev/null || { gem install bundler --no-rdoc --no-ri; }"
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
