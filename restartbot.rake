## Restart a Heroku Web Application
## Adapted from a script by mscottford for restarting workers: https://gist.github.com/2028552

## Instructions:
## * Save this script in lib/tasks
## * Gemfile: gem 'heroku-api', :git => 'https://github.com/heroku/heroku.rb.git'
## * Commit Gemfile* and lib/tasks
## * $ heroku config:add APP_NAME='name of the Heroku app'
## * $ heroku config:add HEROKU_API_KEY='the API key found on the Heroku "My Account" page'
## * Deploy and test with $ heroku run rake heroku:webs:restart[10]  (Look at process uptime with $ heroku ps)
##   ALT: Export the config variables above into the enviroment and run locally $ rake heroku:webs:restart
## * Create a Heroku Scheduler cronjob that runs `rake heroku:webs:restart[10]` to automate restarting at regular intervals

namespace :heroku do
    namespace :bots do
        desc "Restart the webserver by restarting all Heroku 'bot' dynos (optionally sleeping between each process-restart)"
        task :restart, [:sleep] do |t, args|
            args.with_defaults sleep:0
            heroku = Heroku::API.new
            response = heroku.get_ps(ENV['APP_NAME'])
            webs = response.body.map {|item| item['process'] }.select { |item| item =~ /bot/ }
            webs.each do |bot|
                puts "Restarting #{bot}"
                heroku.post_ps_restart(ENV['APP_NAME'], 'ps' => bot) rescue nil
                sleep args.sleep.to_i
            end
        end
    end
end