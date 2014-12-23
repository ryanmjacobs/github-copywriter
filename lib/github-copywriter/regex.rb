# encoding: utf-8
################################################################################
# github-copywriter/regex.rb
#
# All of the regex that's behind this amazing project :)
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com>
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
        # @return [Hash] {:new_content, :copyrights_found, :copyrights_updated}
        #
        # Example return hashes:
        # ======================
        #
        # Input -- an out-of-date copyright:
        #   "...Copyright 2013..."
        # Return:
        #   {:content => "...Copyright 2014...", :copyrights_found => 1, :copyrights_updated => 1}
        #
        # Input -- an already up-to-date copyright:
        #   "...Copyright 2014..."
        # Return:
        #   {:content => "...Copyright 2014...", :copyrights_found => 1, :copyrights_updated => 0}
        #
        # Input -- no copyright whatsoever:
        #   "...no copyright here..."
        # Return:
        #   {:content => "...no copyright here...", :copyrights_found => 0, :copyrights_updated => 0}
        def update_copyright(year, old_content)
            data = {
                :content => "",
                :copyrights_found => 0,
                :copyrights_updated => 0
            }

            # All teh regex
            prefix = /([Cc]opyright( \([Cc]\)| ©)?|\([Cc]\)|©) /
            suffix = /(\.| |$)/
            comma_sep = /((\d{4},|\d{4}-\d{4},)*)/
            regexs = [
                # Singular -> (c) 2012 -> (c) 2014
                # for any year
                { :regex => /#{prefix}\d{4}#{suffix}/, :replace => "\\1 #{year}\\3" },

                # Multiple comma separated, ending w/ year_before
                # (c) 2009-2011,2013 -> (c) 2009-2011,2013-2014
                # for year before
                { :regex => /#{prefix}#{comma_sep}#{year-1}#{suffix}/, :replace => "\\1 \\3#{year-1}-#{year}\\5" },

                # Multiple comma separated, ending w/ some_year DASH year_before
                # (c) 2008-2010,2012-2013 -> (c) 2008-2010,2012-2014
                # for year before
                { :regex => /#{prefix}#{comma_sep}((\d{4}-)?#{year-1})#{suffix}/, :replace => "\\1 \\3\\6#{year}\\7" },

                # Multiple comma separated with dash
                # (c) 2009,2012 -> (c) 2009,2012,2014
                # (c) 2009-2012 -> (c) 2009-2012,2014
                # for any year
                { :regex => /#{prefix}#{comma_sep}((\d{4}-)?\d{4})#{suffix}/, :replace => "\\1 \\3\\5,#{year}\\7" },
            ]

            already_updated = /#{prefix}#{comma_sep}(\d{4}-)?#{year}#{suffix}/
            has_copyright   = /#{prefix}#{comma_sep}(\d{4}-)?\d{4}#{suffix}/

            # Loop through each line of the input text
            old_content.lines.each do |line|
                # Is there even a copyright? If there isn't, goto the next line.
                if not (has_copyright === line) then
                    data[:content] << line
                    next
                end

                # Are we already updated? If so, goto the next line.
                if (already_updated === line) then
                    data[:copyrights_found] += 1
                    data[:content] << line
                    next
                end

                # Loop through our regex until we get one to work
                regexs.each do |r|
                    data[:copyrights_found] += 1 if (r[:regex] === line)
                    updated_line = line.gsub(r[:regex], r[:replace])

                    # Did the regex update the copyright? If so, goto the next line.
                    if updated_line != line then
                        data[:content] << updated_line
                        data[:copyrights_updated] += 1
                        break
                    end
                end
            end

            return data
        end
    end
end
