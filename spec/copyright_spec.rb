require "spec_helper"

###
# This spec desperately needs a rewrite.
# It works, but the display is all wrong
# and unreadable.
#
# (Sorry, I'm still learning how to format my rpecs.)
###

copyrights = [
    { :old => "Copyright 1970",     :new => "Copyright 2014" },
    { :old => "copyright 1970",     :new => "copyright 2014" },

    { :old => "Copyright (C) 1970", :new => "Copyright (C) 2014" },
    { :old => "copyright (c) 1970", :new => "copyright (c) 2014" },
    { :old => "Copyright © 1970",   :new => "Copyright © 2014" },
    { :old => "copyright © 1970",   :new => "copyright © 2014" },

    { :old => "(c) 1970",           :new => "(c) 2014" },
    { :old => "(C) 1970",           :new => "(C) 2014" },
    { :old => "© 1970",             :new => "© 2014" },
]

# ./lib/github-copywriter/regex.rb
describe Copywriter do
    regex = Copywriter::Regex

    # Copywriter::Regex.update_copyright ->
    #     should return the updated copyright if the input was out of date
    context "an out-of-date copyright..." do
        copyrights.each do |copyright|
            updated_copyright = regex.update_copyright(2014, copyright[:old])
            it { expect(updated_copyright).to eq(copyright[:new]) }
        end
    end

    # Copywriter::Regex.update_copyright ->
    #     should return nil if the input was up-to-date
    context "an up-to-date copyright..." do
        copyrights.each do |copyright|
            updated_copyright = regex.update_copyright(2014, copyright[:new])
            it { expect(updated_copyright).to be(nil) }
        end
    end
end
