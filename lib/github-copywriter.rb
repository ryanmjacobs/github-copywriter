################################################################################
# github-copywriter
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com
################################################################################

require "highline/import"
require "octokit"
require "base64"
require "colorize"
require "pp" # debug tool

module Copywriter
    extend self

    VERSION    = "0.0.1"
    COMMIT_MSG = "Update copyright. ♥ github-copywriter\nFor more info, visit http://ryanmjacobs.github.io/github-copywriter"

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

        # Check if the basic_auth worked; TODO: Find a better way to do this
        begin
            @client.authorizations
        rescue Octokit::Unauthorized
            puts "error: Bad credentials".red
            exit
        end
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
        if file[:type] != "file" then raise "error: #{file_path} on #{repo} is not a file!" end

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
        if content != old_content then
            @modified_files << {:path => file_path, :content => content}
            puts "  #{file_path} is now up-to-date.".green
        else
            puts "  #{file_path} was already up-to-date."
        end
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

        # Return if we don't have any files to commit
        if files.size == 0 then return end

        # Force file_mode to be either 100644 or 100775
        if file_mode != "100644" or file_mode != "100775" then
           file_mode = "100644"
        end

        # Construct temp. tree of files to commit
        tree = Array.new
        files.each do |file|
            blob_sha = @client.create_blob(repo, Base64.encode64(file[:content]), "base64")

            tree << {
                :path => file[:path],
                :mode => file_mode,
                :type => "blob",
                :sha  => blob_sha
            }
        end

        # Contruct final tree to commit
        latest_commit = @client.ref(repo, ref).object
        base_tree     = @client.commit(repo, latest_commit.sha).commit.tree
        new_tree      = @client.create_tree(repo, {:base_tree => base_tree.sha, :tree => tree})

        # Commit final tree
        new_commit    = @client.create_commit(repo, commit_msg, new_tree.sha, latest_commit.sha).sha
        updated_ref   = @client.update_ref(repo, ref, new_commit.sha)
    end

    def run!(options={})
        # Default options
        options = {all: false, skip_forks: false}.merge(options)

        if options[:all] then
            repos = @client.repositories()
        else
            repos = Array.new
            options[:repos].each do |r|
                name = @client.login+"/"+File.basename(r)
                if @client.repository?(name) then
                    repos << @client.repository(name)
                else
                    puts "error: repo \"#{name}\" does not exist!".red
                    exit
                end
            end
        end

        # Loop through each repo
        repos.each do |repo|

            next if options[:skip_forks] and repo[:fork]

            # Get repo info
            repo_name     = repo[:full_name]
            ref           = "heads/#{repo[:default_branch]}"
            latest_commit = @client.ref(repo_name, ref).object
            root_tree     = @client.commit(repo_name, latest_commit.sha).commit.tree
            puts "\n"+repo_name+":"

            # Grab the *whole* tree
            tree = @client.tree(repo_name, root_tree.sha, :recursive => true)

            # warn user about truncation
            if tree[:truncated] then
                puts "  warning: tree truncated because number of items exceeded limit.".yellow
                puts "           If you feel like fixing this, see issue #xx".yellow
                puts "           http://github.com/ryanmjacobs/github-copywriter/xx".yellow
            end

            # Stores updated files until we commit
            # @modified_files is a hash {:path, :content}
            @modified_files = Array.new

            # Loop through all of the tree's blobs
            tree[:tree].each do |file|
                next if file[:type] != "blob"

                if accepted_name?(file[:path]) then
                    update_copyright(repo_name, ref, file[:path])
                end
            end

            # Commit stored up files
            if @modified_files.size > 0 then
                print "  Committing #{@modified_files.size} files..."
                commit_files(repo_name, ref, "100644", @modified_files, COMMIT_MSG)
                puts " done"
            else
                puts "  No files needed to be commited."
            end
        end
    end

    private :update_copyright, :accepted_name?, :commit_files
end
