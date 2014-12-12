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
    CUR_YEAR = time.year

    def login!
        # Grab username and pass
        puts "Obtaining OAuth2 access_token from github."
        username = ask("GitHub username: ") { |q| q.echo = true }
        password = ask("GitHub password: ") { |q| q.echo = "*" }

        # Auth to GitHub
        @client = Octokit::Client.new(:login => username, :password => password)
    end

    ##
    # Returns true if this is a file that we will update.
    def accepted_name?(filename)
        filename = File.basename(filename)

        names      = ["readme", "license"]
        extensions = [".md", ".txt", ".html"]

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

        # Have to do separate assignments b/c ruby shares strings,
        # TODO: find a way around this
        content     = Base64.decode64(file[:content])
        old_content = Base64.decode64(file[:content])

        # Do the substitution
        #
        # Matches:
        #     Copyright 2014
        #     copyright 2014
        #
        #     Copyright (C) 2014
        #     copyright (c) 2014
        #     Copyright © 2014
        #     copyright © 2014
        #
        #     (c) 2014
        #     (C) 2014
        #     © 2014
        begin
            content.gsub!(/([Cc]opyright( \([Cc]\)| ©)|\([Cc]\)|©) \d{4}/, "\\1 #{CUR_YEAR}")
        rescue
            # try w/o "©" symbol if we had errors
            content.gsub!(/([Cc]opyright( \([Cc]\))|\([Cc]\)) \d{4}/, "\\1 #{CUR_YEAR}")
        end

        # Only commit if we need to
        if content != old_content
            commit_msg = "Update copyright. ♥ github-copywriter\nFor more info, visit http://ryanmjacobs.github.io/github-copywriter"
            commit_files(repo, ref, "100644", file_path, content, commit_msg)
        end

        puts "#{repo}: #{file_path} is up-to-date."
    end

    ##
    # Commits files to a GitHub repo.
    #
    # repo         = Repo to commit to,      e.g. "user/repo_name"
    # ref          = Branch to commit to,    e.g. "heads/master"
    # file_mode    = Filemode on repo,       e.g. "100644"
    # files        = Array of {:path, :content}
    # commit_msg   = Commit message,         e.g. "Update file.rb"
    #
    def commit_files(repo, ref, file_mode, files, commit_msg)

        # Force file_mode to be either 100644 or 100775
        if file_mode != "100644" or file_mode != "100775" then
           file_mode = "100644"
        end

        sha_latest_commit = @client.ref(repo, ref).object.sha
        sha_base_tree     = @client.commit(repo, sha_latest_commit).commit.tree.sha

        blob_sha          = @client.create_blob(repo, Base64.encode64(file_content), "base64")

        sha_new_tree = @client.create_tree(repo, 
        {
          :base_tree => sha_base_tree,
          :tree => [
            {
              :path => file_path,
              :mode => file_mode,
              :type => "blob",
              :sha => blob_sha
            }
          ],
        }).sha

        sha_new_commit = @client.create_commit(repo, commit_msg, sha_new_tree, sha_latest_commit).sha
        updated_ref    = @client.update_ref(repo, ref, sha_new_commit)

        # http://mattgreensmith.net/2013/08/08/commit-directly-to-github-via-api-with-octokit/
    end

    def run!(options={})
        # Default options
        options = {all: false, skip_forks: false}.merge(options)

        if options[:all]
            repos = @client.repositories()
        else
            repos = []
            options[:repos].each do |r|
                name = @client.login+"/"+File.basename(r)
                if @client.repository? name
                    repos << @client.repository(name)
                else
                    puts "error: repo \"#{name}\" does not exist!"
                    exit
                end
            end
        end

        # Loop through each repo
        repos.each do |repo|
            puts

            next if options[:skip_forks] and repo[:fork]

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

    private :update_copyright, :accepted_name?, :commit_files
end
