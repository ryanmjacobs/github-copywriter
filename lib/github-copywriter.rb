require "highline/import"
require "octokit"
require "base64"

module Copywriter
    extend self

    VERSION = "0.0.1"

    # Get time/date
    time = Time.now
   #CUR_YEAR = time.year
    CUR_YEAR = 2015

    def login!
        # Grab username and pass
        puts "Obtaining OAuth2 access_token from github."
        username = ask("GitHub username: ") { |q| q.echo = true }
        password = ask("GitHub password: ") { |q| q.echo = "*" }

        # Auth to GitHub
        @client = Octokit::Client.new(:login => username, :password => password)

        # Get user repos
        # https://developer.github.com/v3/repos/#list-your-repositories
        @user_repos = @client.repositories(:user => @client.login)

        puts
    end

    ##
    # Updates copyright using regex, then commits it.
    #
    #   input base64 encoded file
    def update_copyright(base64_input)
        input = Base64.decode64(base64_input)

        input.gsub!(/(Copyright.*)\d{4}/, "\\1#{CUR_YEAR}")
        puts input

        # http://mattgreensmith.net/2013/08/08/commit-directly-to-github-via-api-with-octokit/
    end

    ##
    # Loop through each file in each repo and update the copyright.
    def update_all_copyrights
        @user_repos.each do |repo|
            repo = repo["full_name"]
           #ref  = repo["default_branch"]
            ref  = "HEAD"

            begin
                readme  = @client.contents(repo, :path => "README.md")["content"]
                license = @client.contents(repo, :path => "LICENSE")  ["content"]

                update_copyright license
            rescue
                puts "error"
            end
        end
    end

    private :update_copyright
    attr_reader :client
end
