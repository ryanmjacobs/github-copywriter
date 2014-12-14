# github-copywriter

Updates your copyrights... so you don't have to!

`$ gem install github-copywriter`

---

### Update specific repos
`$ github-copywriter MyCoolRepo MyOtherCoolRepo`

### Update all repos
`$ github-copywriter --all`

### Update all repos, excluding forks
`$ github-copywriter --all --skip-forks`

---

## Contributing
Please submit issues or feature requests [here](//github.com/ryanmjacobs/github-copywriter/issues).
Questions and comments are fine too :)

Feel free to [fork](//github.com/ryanmjacobs/github-copywriter) this project, and:

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
