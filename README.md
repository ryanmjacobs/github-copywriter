# github-copywriter
[![Build Status](https://travis-ci.org/ryanmjacobs/github-copywriter.svg?branch=master)](https://travis-ci.org/ryanmjacobs/github-copywriter)
[![Gem Version](https://badge.fury.io/rb/github-copywriter.svg)](http://badge.fury.io/rb/github-copywriter)

![test-repo demo](https://raw.githubusercontent.com/ryanmjacobs/github-copywriter/master/test_repo_demo.gif)

**See the above commit [here](//github.com/ryanmjacobs/test-repo/commit/7b095e65adf4cedcd7891326ec32c5f526838dd5). Or, see a more complex example [here](https://github.com/ryanmjacobs/test-repo/commit/7fbc410ce1171a2e858972b1c7cfed32b86d98e2).**

## Updates your copyrights... so you don't have to!

```
$ gem install github-copywriter
```
Checkout usage information [here](//ryanmjacobs.github.io/github-copywriter)!

## Contributing
Please submit issues or feature requests [here](//github.com/ryanmjacobs/github-copywriter/issues).
Questions and comments are welcome as well. Checkout
[CONTRIBUTING.md](//github.com/ryanmjacobs/github-copywriter/blob/master/CONTRIBUTING.md)
for more info.

Feel free to [fork](//github.com/ryanmjacobs/github-copywriter/fork) this project, and:

* fix bugs
* add some sweet features
* implement feature requests
* improve the docs and/or this site

## Under the hood
All GitHub API calls are made with [Octokit](//github.com/octokit/octokit.rb).

#### Basic breakdown of the program's logic:
1. Authenticate to GitHub.
2. Loop through each user repo given, and:
    * Update copyrights on files: `README.md`, `LICENSE`, etc.
    * Create a local commit and push to GitHub.
