unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :refinery do

      desc <<-DESC
        Creates the refinery core config for the application.
      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
        # encoding: utf-8
        Refinery::Core.configure do |config|
          config.rescue_not_found = Rails.env.production?
          config.s3_backend = !(ENV['S3_KEY'].nil? || ENV['S3_SECRET'].nil?)
          config.base_cache_key = :rip
          config.site_name = "Religionsfrihet i Praksis"
          config.authenticity_token_on_frontend = true
          config.dragonfly_secret = "#{SecureRandom.hex(24)}"
          config.ie6_upgrade_message_enabled = true
          config.show_internet_explorer_upgrade_message = false
        end
        EOF

        run "mkdir -p #{shared_path}/config/refinery"
        IO.write("#{shared_path}/config/refinery/core.rb", default_template);
      end

      desc <<-DESC
        [internal] Updates the symlink for secret_token.rb file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/refinery/core.rb #{release_path}/config/refinery/core.rb"
      end

    end

    after "deploy:setup",           "deploy:refinery:setup"   unless fetch(:skip_refinery_setup, false)
    after "deploy:finalize_update", "deploy:refinery:symlink"
  end

end
