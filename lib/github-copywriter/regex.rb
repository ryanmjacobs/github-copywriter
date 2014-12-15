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

        # Updates copyright using regex, then commits it.
        #
        # @param year    [Numeric] Year to update to,   e.g. 2024
        # @param content [String]  Text with outdated copyright
        # @return [String] Text with updated copyright. Nil if file was already
        # up to date.
        def update_copyright(year, old_content)
            # Have to do separate assignments b/c ruby shares strings,
            # TODO: find a way around this

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
                new_content = \
                old_content.gsub(/([Cc]opyright( \([Cc]\)| ©)?|\([Cc]\)|©) \d{4}/, "\\1 #{year}")
            rescue
                # try w/o "©" symbol if we had errors
                new_content = \
                old_content.gsub(/([Cc]opyright( \([Cc]\))?|\([Cc]\)) \d{4}/, "\\1 #{year}")
            end

            # Only commit if we need to
            if new_content != old_content then
                return new_content
            else
                return nil
            end
        end
    end
end
