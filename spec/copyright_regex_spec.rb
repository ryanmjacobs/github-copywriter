# encoding: utf-8
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

garbage_text = [
    "sjdfhaksjdfashdjfahskdjfh",
    "asdjfasdf",
    "hello these are words",
    "thing thing thing",
    "NOTCOPYRIGHT",
    "NOT COPYRIGHT",
    "(c) (c) (C)",
    "_dfasdf_",
    "© © ©",
    "#@$%#%@#%23"
]

# ./lib/github-copywriter/regex.rb
describe Copywriter do
    regex = Copywriter::Regex

    # Copywriter::Regex.update_copyright
    context "an out-of-date copyright..." do
        copyrights.each do |copyright|
            updated_copyright = regex.update_copyright(2014, copyright[:old])

            it { expect(updated_copyright[:updated_now])    .to be(true) }
            it { expect(updated_copyright[:found_copyright]).to be(true) }
            it { expect(updated_copyright[:content])        .to eq(copyright[:new]) }
        end
    end

    # Copywriter::Regex.update_copyright
    context "an up-to-date copyright..." do
        copyrights.each do |copyright|
            updated_copyright = regex.update_copyright(2014, copyright[:new])

            it { expect(updated_copyright[:updated_now])    .to be(false) }
            it { expect(updated_copyright[:found_copyright]).to be(true) }
            it { expect(updated_copyright[:content])        .to eq(copyright[:new]) }
        end
    end

    # Copywriter::Regex.update_copyright
    context "garbage text input..." do
        garbage_text.each do |garbage|
            updated_copyright = regex.update_copyright(2014, garbage)

            it { expect(updated_copyright[:updated_now])    .to be(false) }
            it { expect(updated_copyright[:found_copyright]).to be(false) }
            it { expect(updated_copyright[:content])        .to eq(garbage) }
        end
    end
end
