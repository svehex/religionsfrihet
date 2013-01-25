unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :token do

      desc <<-DESC
        Creates the secret token for the application.
      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
        ReligionsfrihetNo::Application.config.secret_token = '#{`bundle exec rake secret`}'
        EOF

        run "mkdir -p #{shared_path}/config"
        IO.write("#{shared_path}/config/secret_token.rb", default_template);
      end

      desc <<-DESC
        [internal] Updates the symlink for secret_token.rb file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/secret_token.rb #{release_path}/config/secret_token.rb"
      end

    end

    after "deploy:setup",           "deploy:token:setup"   unless fetch(:skip_token_setup, false)
    after "deploy:finalize_update", "deploy:token:symlink"
  end

end
