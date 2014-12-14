## Contributing

### Introduction
I'm pretty much open to anything really. If you have a feature you want to
implement, first create an issue for it (so I can see what you're trying to
achieve). Then submit a pull request later when
you're done with it.

Try best you can to keep the code consistent. The only thing you really
need to worry about is the indentation. Please set your editor to use 4-space
indentation.

If I merge any of your pull requests, big or small, I will add you to the
[list of contributors](//github.com/ryanmjacobs/github-copywriter/blob/master/CONTRIBUTORS.md)
with a small note of what you did. If you want to update it to
include your website and/or email, just submit a PR.

### Setup
To start hacking away, fork and clone the project.
```
$ git clone https://github.com/YourUsername/github-copywriter
$ cd github-copywriter
```

### Adding features and fixing bugs
Create an aptly named branch off the master.
```
$ git checkout master
$ git checkout -b add-rainbow-text
```

Make some modifications/additions.
```
$ do some work...
$ add some commits...
```

Push changes to the origin.
```
git push origin add-rainbow-text
```

### Staying in sync with the upstream
Set and fetch the upstream remote.
```
$ git remote add upstream https://github.com/ryanmjacobs/github-copywriter
$ git fetch upstream
```

And every once in a while sync your `master` to `upstream/master`.
```
$ git fetch upstream
$ git checkout master
$ git merge upstream/master
$ git push origin master
```
