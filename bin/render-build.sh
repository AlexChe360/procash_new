set -o errexit

bundle install
bundle exec rake assets:precompile --trace
bundle exec rake assets:clean --trace
bundle exec rake db:migrate



