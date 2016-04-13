set :stage, :staging

set :deploy_to, '/var/www/<%= app_name.gsub("_", "-") %>-staging.makandra.de'
set :rails_env, 'staging'
set :branch, 'master'

server 'c23.staging.makandra.de', user: 'deploy-<%= app_name %>_s', roles: %w(app web cron db) # first is primary
server 'c42.staging.makandra.de', user: 'deploy-<%= app_name %>_s', roles: %w(app web)
