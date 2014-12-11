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
        puts

        # Auth to GitHub
        @client = Octokit::Client.new(:login => username, :password => password)

        # Get user repos
        # https://developer.github.com/v3/repos/#list-your-repositories
        @user_repos = @client.repositories(:user => @client.login)
    end

    attr_reader :client
end
