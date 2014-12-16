# encoding: utf-8
################################################################################
# github-copywriter/github-copywriter.rb
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com
################################################################################

require "github-copywriter/regex"
require "github-copywriter/version"
require "github-copywriter/octikit_wrapper"

require "base64"
require "octokit"
require "colorize"

class Copywriter

    COMMIT_MSG = "Update copyright. ♥ github-copywriter\n\nFor more info, visit http://ryanmjacobs.github.io/github-copywriter"

    def initialize(username, password)
        # Auth to GitHub
        @client = Octokit::Client.new(:login => username, :password => password)

        # Check if the basic_auth worked; TODO: Find a better way to do this
        begin
            @client.authorizations
        rescue Octokit::Unauthorized
            puts "error: Bad credentials.".red
            exit
        rescue Faraday::ConnectionFailed
            puts "error: Connection failed.".red
            exit
        end
    end

    def run!(options={})
        # Default options
        options = {
            all_repos: false,
            skip_forks: false,
            year: nil,
            branches: nil
        }.merge(options)

        if options[:all_repos] then
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

        # Get copyright year
        cur_year = options[:year] || Time.now.year

        # Loop through each repo
        repos.each do |repo|

            # Skip if repo is a fork and --skip-forks is on
            next if options[:skip_forks] and repo[:fork]

            # Repo name
            repo_name = repo[:full_name]
            puts "\n#{repo_name}:".cyan

            # Repo refs (branches) to loop through
            if options[:branches] == nil then
                # Get every single ref (branch) by default
                refs = @client.refs(repo_name, "heads").map { |r| r[:ref].sub("refs/", "") }
            else
                # User-supplied branches
                refs = options[:branches].map { |branch| "heads/#{branch}" }
            end

            # Loop through each ref
            refs.each do |ref|
                puts "  #{ref}:".yellow

                # Grab the *whole* tree
                begin
                    latest_commit = @client.ref(repo_name, ref).object
                    root_tree     = @client.commit(repo_name, latest_commit.sha).commit.tree
                    whole_tree    = @client.tree(repo_name, root_tree.sha, :recursive => true)
                rescue Octokit::NotFound
                    puts "error: ref #{ref} not found.".red
                    exit
                end

                # Warn the user about truncation
                if whole_tree[:truncated] then
                    puts "    warning: tree truncated because number of items exceeded limit.".yellow
                    puts "             If you feel like fixing this, see issue #xx".yellow
                    puts "             http://github.com/ryanmjacobs/github-copywriter/xx".yellow
                end

                # Stores updated files until we commit
                # @modified_files is a hash {:path, :content}
                @modified_files = Array.new

                # Loop through all of whole_tree's blobs
                whole_tree[:tree].each do |file|
                    next if file[:type] != "blob"

                    if Copywriter::Regex.accepted_name?(file[:path]) then
                        # Grab file from repo
                        file = @client.contents(repo_name, :path => file[:path], :ref => ref)
                        if file[:type] != "file" then raise "error: #{file_path} on #{repo} is not a file!" end

                        # Update the copyright
                        new_content = Copywriter::Regex.update_copyright(cur_year, Base64.decode64(file[:content]))

                        # Add to list of files to commit, only if the file has changed
                        if new_content != nil then
                            @modified_files << {:path => file[:path], :content => new_content}
                            puts "    #{file[:path]} is now up-to-date.".green
                        else
                            puts "    #{file[:path]} is already up-to-date."
                        end
                    end
                end

                # Commit stored up files
                if @modified_files.size > 0 then
                    print "    Committing #{@modified_files.size} files..."
                    commit_files(repo_name, ref, "100644", @modified_files, COMMIT_MSG)
                    puts " done"
                else
                    puts "    No files needed to be commited."
                end
            end
        end
    end
end
