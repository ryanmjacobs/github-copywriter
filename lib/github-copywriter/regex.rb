# encoding: utf-8
################################################################################
# github-copywriter/regex.rb
#
# All of the regex that's behind this amazing project :)
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com
################################################################################

class Copywriter
    module Regex
        extend self

        # Returns true if this is a file that we will update, (otherwise false).
        #
        # @return [Boolean] True if name is accepted. False if otherwise.
        def accepted_name?(filename)
            filename = File.basename(filename)

            names      = ["readme", "license"]
            extensions = [".md", ".txt", ".html"]

            if names.include?      filename.downcase               then return true end
            if extensions.include? File.extname(filename.downcase) then return true end

            return false
        end

        # Updates copyright using regex.
        #
        # @param year    [String] Year to update to, e.g. "2024"
        # @param content [String] Text with outdated copyright
        # @return [String] Hash object {:new_content, :updated_now, :found_copyright}
        #
        # Example return hashes:
        #
        # Input:
        #   "...Copyright 2014..."
        # Return:
        #   {:content => "...Copyright 2014...", :updated_now => false, :found_copyright => true}
        #
        # Input:
        #   "...no copyright here..."
        # Return:
        #   {:content => "...no copyright here...", :updated_now => false, :found_copyright => false}
        #
        # Input:
        #   "...Copyright 2013..."
        # Return:
        #   {:content => "...Copyright 2014...", :updated_now => true, :found_copyright => true}
        def update_copyright(year, old_content)
            data = {
                :content => "",
                :updated_now => false,
                :found_copyright => false
            }

            # The Glorious Regular Expression
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
            utf_regex     = /([Cc]opyright( \([Cc]\)| ©)?|\([Cc]\)|©) \d{4}/
            ascii_regex   = /([Cc]opyright( \([Cc]\))?|\([Cc]\)) \d{4}/
            regex_replace = "\\1 #{year}"

            # Do the substitution
            begin
                # Do UTF-8 Regex

                data[:found_copyright] = old_content.grep(utf_regex)
                data[:content] = old_content.gsub(utf_regex, regex_replace)
            rescue
                # Do Ascii Regex if the above fails
                data[:found_copyright] = old_content.grep(ascii)
                data[:content] = old_content.gsub(ascii_regex, regex_replace)
            end

            # Update whether or not we had to update the copyright
            if new_content != old_content then
                content[:updated] = true
            end

            return data
        end
    end
end
