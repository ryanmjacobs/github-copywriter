require "spec_helper"

describe Copywriter do
    regex = Copywriter::Regex

    # Accepted
    it { expect(regex.accepted_name?      "README")  .to be(true) }
    it { expect(regex.accepted_name?     "LICENSE")  .to be(true) }
    it { expect(regex.accepted_name?   "README.md")  .to be(true) }
    it { expect(regex.accepted_name?  "LICENSE.md")  .to be(true) }

    # Accepted
    it { expect(regex.accepted_name? "whatever.md")  .to be(true) }
    it { expect(regex.accepted_name?   "thing.html") .to be(true) }

    # Not Accepted
    it { expect(regex.accepted_name?      "garbage") .to be(false) }
    it { expect(regex.accepted_name?    "colors.py") .to be(false) }
    it { expect(regex.accepted_name? "list_files.c") .to be(false) }
    it { expect(regex.accepted_name?   "coolLib.js") .to be(false) }
end
