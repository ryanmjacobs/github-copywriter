Updates your copyrights... so you don't have to!

`$ gem install github-copywriter`

---

## Basic Usage

### Update specific repos
`$ github-copywriter MyCoolRepo MyOtherCoolRepo`

### Update all repos
`$ github-copywriter --all`

### Do a dry-run
`$ github-copywriter --all --dry-run`

---

## More Usage

### Update all repos, excluding forks
`$ github-copywriter --all --skip-forks`

<h3 id="year-example-header">Update all repos to 2099</h3>
<code id="year-example-code">$ github-copywriter --all --year 2099</code>

### Update only branches: gh-pages and dev
`$ github-copywriter --branches gh-pages,dev MyRepo`

---

## Contributing
Please submit issues or feature requests [here](//github.com/ryanmjacobs/github-copywriter/issues).
Questions and comments are welcome as well. Checkout
[CONTRIBUTING.md](//github.com/ryanmjacobs/github-copywriter/blob/master/CONTRIBUTING.md)
for more info.

<br>
Feel free to [fork](//github.com/ryanmjacobs/github-copywriter/fork) this project, and:

* fix bugs
* add some sweet features
* implement feature requests
* improve the docs and/or this site

---

## Under the hood
All GitHub API calls are made with [Octokit](//github.com/octokit/octokit.rb).

####Basic breakdown of the program's logic:
1. Authenticate to GitHub.
2. Loop through each user repo given, and:
    * Update copyrights on files: `README.md`, `LICENSE`, etc.
    * Create a local commit and push to GitHub.
