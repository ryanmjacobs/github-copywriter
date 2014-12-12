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
    # Returns true if this is a file that we will update.
    def accepted_name?(filename)
        filename = File.basename(filename)

        names      = ["readme", "license"]
        extensions = [".md", ".txt"]

        if names.include?      filename.downcase               then return true end
        if extensions.include? File.extname(filename.downcase) then return true end
    end

    ##
    # Updates copyright using regex, then commits it.
    #
    # repo         = Repo to commit to,      e.g. "user/repo_name"
    # ref          = Branch to commit to,    e.g. "heads/master"
    # file_path    = File path on repo,      e.g. "readme", "src/file.rb", etc.
    #
    def update_copyright(repo, ref, file_path)

        # Grab file from repo
        file = @client.contents(repo, :path => file_path)
        if file[:type] != "file" then raise "Error: #{file_path} on #{repo} is not a file!" end
        contents = Base64.decode64(file[:content])

        # Do the subsitution
        contents.gsub!(/(Copyright.*)\d{4}/, "\\1#{CUR_YEAR}")

        # Commit update file to repo
        file_mode  = "100644"
        commit_msg = "Update copyright to #{CUR_YEAR}. ♥ github-copywriter"
        commit_to_repo(repo, ref, file_mode, file_path, contents, commit_msg)
    end

    ##
    # Commits a file to a GitHub repo.
    #
    # repo         = Repo to commit to,      e.g. "user/repo_name"
    # ref          = Branch to commit to,    e.g. "heads/master"
    # file_mode    = Filemode on repo,       e.g. "100644"
    # file_path    = File path on repo,      e.g. "readme", "src/file.rb", etc.
    # file_content = File content to commit, e.g. "readme", "src/file.rb", etc.
    # commit_msg   = Commit message,         e.g. "Update file.rb"
    #
    def commit_to_repo(repo, ref, file_mode, file_path, file_content, commit_msg)

        # Force file_mode to be either 100644 or 100775
        if file_mode != "100644" or file_mode != "100775" then
           file_mode = "100644"
        end

        sha_latest_commit = @client.ref(repo, ref).object.sha
        sha_base_tree     = @client.commit(repo, sha_latest_commit).commit.tree.sha
        blob_sha          = @client.create_blob(repo, Base64.encode64(file_content), "base64")

        sha_new_tree = @client.create_tree(repo, 
            [ { :path => file_path, 
                :mode => file_mode,
                :type => "blob", 
                :sha => blob_sha } ], 
        {:base_tree => sha_base_tree }).sha

        sha_new_commit = @client.create_commit(repo, commit_msg, sha_new_tree, sha_latest_commit).sha
        updated_ref    = @client.update_ref(repo, ref, sha_new_commit)

        # http://mattgreensmith.net/2013/08/08/commit-directly-to-github-via-api-with-octokit/
    end

    def run!(options={})
        # Default options
        options = {skip_forks: true}.merge(options)

        # Loop through each repo.
        @client.repositories().each do |repo|

            # Skip some repos based on options
            next if options[:skip_forks] and repo[:fork]
            next if repo[:name] != "ryans_dotfiles"

            # Get repo info
            repo_name  = repo[:full_name]
            ref        = "heads/#{repo[:default_branch]}"
            commit_sha = @client.ref(repo_name, ref).object.sha
            tree_sha   = @client.commit(repo_name, commit_sha).commit.tree.sha

            # Update certain files based on name/extension
            @client.tree(repo_name, tree_sha, :recursize => true)[:tree].each do |file|
                file_path = file[:path]

                if accepted_name?(file_path) then
                    update_copyright(repo_name, ref, file_path)
                end
            end
        end
    end

    private :update_copyright, :accepted_name?, :commit_to_repo
end
