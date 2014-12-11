require "highline/import"
require "octokit"
require "base64"

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

    ##
    # Updates copyright using regex.
    #
    #   input base64 encoded file
    # returns base64 encoded file
    def update_copyright(base64_input)
        input = Base64.decode64(base64_input)
        puts input
    end

    ##
    # Loop through each file in each repo and update the copyright.
    def update_all_copyrights
        @user_repos.each do |repo|
            repo = repo["full_name"]
            ref  = repo["default_branch"]
        end
    end

    private :update_copyright
    attr_reader :client
end
