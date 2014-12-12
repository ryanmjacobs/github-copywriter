################################################################################
# github-copywriter
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com
################################################################################

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

    def update_all_copyrights(options={})
        # Default options
        options = {skip_forks: false}.merge(options)

        # Loop through each file in each repo and update the copyright.
        @client.repositories().each do |repo_object|
            # Skip forked repositories
            next if options[:skip_forks]

            # Get repo info
            repo       = repo_object[:full_name]
            ref        = "heads/#{repo_object[:default_branch]}"
            commit_sha = @client.ref(repo, ref).object.sha
            tree_sha   = @client.commit(repo, commit_sha).commit.tree.sha

            # Build list of files to update
            paths = Array.new
            tree = @client.tree(repo, tree_sha, :recursize => true)[:tree]
            tree.each do |file|
                paths << file[:path]
            end

=begin
            begin
                readme  = @client.contents(repo, :path => "README.md")[:content]
                license = @client.contents(repo, :path => "LICENSE")  [:content]

                update_copyright license
            rescue
                puts "error"
            end
=end
        end
    end

    private :update_copyright
    attr_reader :client
end
