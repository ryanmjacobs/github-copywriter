require "spec_helper"

describe Copywriter do
    include Copywriter

    it { expect(accepted_name?      "README")  .to be(true) }
    it { expect(accepted_name?     "LICENSE")  .to be(true) }
    it { expect(accepted_name?   "README.md")  .to be(true) }
    it { expect(accepted_name?  "LICENSE.md")  .to be(true) }
    it { expect(accepted_name? "whatever.md")  .to be(true) }
    it { expect(accepted_name?   "thing.html") .to be(true) }
    it { expect(accepted_name? "my_site.html") .to be(true) }

    it { expect(accepted_name? "sadkfhasdfga") .to be(false) }
    it { expect(accepted_name?    "colors.py") .to be(false) }
    it { expect(accepted_name? "list_files.c") .to be(false) }
    it { expect(accepted_name?       "prog.c") .to be(false) }
end
