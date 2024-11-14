set -o errexit

bundle install
RAILS_ENV=production bundle exec rake assets:precompile --trace
RAILS_ENV=production bundle exec rake assets:precompile --trace
bundle exec rake db:migrate



