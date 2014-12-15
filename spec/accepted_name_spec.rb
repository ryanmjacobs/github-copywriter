require "spec_helper"

###
# This spec desperately needs a rewrite.
# It works, but the display is all wrong
# and unreadable.
#
# (Sorry, I'm still learning how to format my rpecs.)
###

describe Copywriter do
    regex = Copywriter::Regex

    # Accepted
    context "a filename matching README, LICENSE, or with the extensions .md, .txt, or .html" do
        it { expect(regex.accepted_name?      "README")  .to be(true) }
        it { expect(regex.accepted_name?     "LICENSE")  .to be(true) }
        it { expect(regex.accepted_name?   "README.md")  .to be(true) }
        it { expect(regex.accepted_name?  "LICENSE.md")  .to be(true) }

        it { expect(regex.accepted_name? "whatever.md")  .to be(true) }
        it { expect(regex.accepted_name?   "thing.html") .to be(true) }
    end

    # Not Accepted
    context "a filename NOT matching README, LICENSE, or with the extensions .md, .txt, or .html" do
        it { expect(regex.accepted_name?      "garbage") .to be(false) }
        it { expect(regex.accepted_name?    "colors.py") .to be(false) }
        it { expect(regex.accepted_name? "list_files.c") .to be(false) }
        it { expect(regex.accepted_name?   "coolLib.js") .to be(false) }
    end
end
