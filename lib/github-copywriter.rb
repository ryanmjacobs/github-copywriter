require "highline/import"
require "octokit"

module Copywriter
    extend self

    VERSION = "0.0.1"

    def login!
        # Grab username and pass
        puts "Obtaining OAuth2 access_token from github."
        username = ask("GitHub username: ") { |q| q.echo = true }
        password = ask("GitHub password: ") { |q| q.echo = "*" }

        # Auth to GitHub
        @client = Octokit::Client.new(:login => username, :password => password)
        @user   = @client.user
    end
end
