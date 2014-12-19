################################################################################
# github-copywriter/octikit_wrapper.rb
#
# Octokit wrapper for commiting multiple files to a GitHub repo.
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com>
################################################################################

class Copywriter
    private
    # Commits files to a GitHub repo.
    # Requires @client to be already authorized with Copywriter.login!
    #
    # @param repo       Repo to commit to,      e.g. "user/repo_name"
    # @param ref        Branch to commit to,    e.g. "heads/master"
    # @param file_mode  Filemode on repo,       e.g. "100644"
    # @param files      Array of {:path, :content}
    # @param commit_msg Commit message,         e.g. "Update file.rb"
    #
    # @example
    #   commit_files("user/repo", "heads/master", "100644", [{:path => "file.md", :content => "files content}], "modify file.md")
    def commit_files(repo, ref, file_mode, files, commit_msg)
        # Return if we don't have any files to commit
        if files.size == 0 then return false end

        # Force file_mode to be either 100644 or 100775
        if file_mode != "100644" or file_mode != "100775" then
           file_mode = "100644"
        end

        begin
            # Construct temp. tree of files to commit
            trees = Array.new
            files.each do |file|
                blob_sha = @client.create_blob(repo, Base64.encode64(file[:content]), "base64")

                trees << {
                    :path => file[:path],
                    :mode => file_mode,
                    :type => "blob",
                    :sha  => blob_sha
                }
            end

            # Contruct the commit
            latest_commit = @client.ref(repo, ref).object
            base_tree     = @client.commit(repo, latest_commit.sha).commit.tree
            new_tree      = @client.create_tree(repo, trees, :base_tree => base_tree.sha)
            new_commit    = @client.create_commit(repo, commit_msg, new_tree.sha, latest_commit.sha)

            # Commit it!
            @client.update_ref(repo, ref, new_commit.sha)
            return true
        rescue
            return false
        end
    end
end
