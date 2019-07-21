# :tada: ugalek.com

[![CircleCI](https://circleci.com/gh/ugalek/ugalek.com/tree/master.svg?style=svg&circle-token=db38b90968b589162837acccfeb72fe8999eac17)](https://circleci.com/gh/ugalek/ugalek.com/tree/master)

Source code of my personal website (written in
<a href="https://swift.org">Swift</a> on top of <a href="http://vapor.codes">:droplet: Vapor</a>).

## Installation

Install [Xcode 9.3 or greater](https://itunes.apple.com/us/app/xcode/id497799835?mt=12). After Xcode has been downloaded, don't forget to open it to finish the installation.

Install Vapor using [Homebrew](https://brew.sh):

```console
brew tap vapor/tap
brew install vapor/tap/vapor
```

Clone the repository:

```console
git clone git@github.com:ugalek/ugalek.com.git
```

Open the project in Xcode:

```console
cd ugalek.com
vapor xcode
```

Run it! Now, you can go to: http://localhost:8080.

## Development

Install [Docker](https://www.docker.com)/

To be sure everything works properly on Linux, you can use the provided Docker configuration:

```console
# Start Docker containers
make docker-up

# Once everything has been done, stop Docker containers
make docker-down
```

Run the test suite:

```console
make test
```

<hr>

<p align="center">Made with :heart: from my cute Mac mini</p>
