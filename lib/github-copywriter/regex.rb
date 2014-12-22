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
        # @return [Hash] {:new_content, :updated_now, :found_copyright}
        #
        # Example return hashes:
        # ======================
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

            # I'm truly sorry for anyone trying to decode these regular
            # expressions. This is the most unreadable regex I have ever
            # written.

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

            already_updated = /#{prefix}#{comma_sep}(\d{4}-)?#{year}( |$)/

            if (already_updated === old_content) then
                data[:content] = old_content
                data[:found_copyright] = true
                return data
            end

            regexs.each_with_index do |r,num|
                data[:found_copyright] = true if (r[:regex] === old_content)
                data[:content] = old_content.gsub(r[:regex], r[:replace])

                if data[:content] != old_content then
                    data[:updated_now] = true
                    return data
                end
            end

            return data
        end
    end
end
