Dockerfile-go-release [![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)][LICENSE]
====

[LICENSE]: https://github.com/tcnksm/dockerfile-gox/blob/master/LICENCE

[tcnksm/go-release Repository | Docker Hub Registry - Repositories of Docker Images](https://registry.hub.docker.com/u/tcnksm/go-release/)

Dockerfile for cross-compiling ([mitchell/gox](https://github.com/mitchellh/gox)) & uploading artifacts to Github Release page ([tcnksm/ghr](https://github.com/tcnksm/ghr)). Compiling and uploading are executed parallelly.


## Supported tags

`tcnksm/go-release` image support below tags. Link is its `Dockerfile`. 

- [`1.5-beta` (1.5-beta/Dockerfile)](https://github.com/tcnksm/dockerfile-gox/blob/master/1.5-beta/Dockerfile)

Tag is correspond to its golang version. 

## Usage

To cross-compile & upload current directory project, 

```bash
$ docker run --rm -v $(pwd):/gopath/${$(pwd)#*${GOPATH}/} -w /gopath/${$(pwd)#*${GOPATH}/} tcnksm/go-release:1.5-beta VERSION USER TOKEN
```

You need to specify `VERSION`, `USER` (Github username), [`GITHUB_TOKEN`](#github-token).

`tcnksm/go-release` calls [mitchell/gox](https://github.com/mitchellh/gox) and [tcnksm/ghr](https://github.com/tcnksm/ghr). To set additional option of them, use `GOX_OPT` and `GHR_OPT` env ver. For example, if you want to set `--replace` option for ghr, set it via docker run`-e` option (`-e "GHR_OPT=--replace"`). 


## Example

For example, to cross-compile and upload [tcnksm/license](https://github.com/tcnksm/license) with `0.1.1` version,

```bash
$ cd $GOPATH/src/github.com/tcnksm/license/
docker run --rm -v $(pwd):/gopath/${$(pwd)#*${GOPATH}/} -w /gopath/${$(pwd)#*${GOPATH}/} tcnksm/go-release:1.5-beta 0.1.1 tcnksm $TOKEN
```

## Build image

To build this image, change directory named by its `$TAG` and run build,

```bash
$ cd $TAG
$ docker build -t tcnksm/go-release:$TAG . 
```

## GitHub Token

To be able to use this step, you will first need to create a GitHub token with an account which has enough permissions to be able to create releases. First goto `Account settings`, then goto `Applications` for the user. Here you can create a token in the `Personal access tokens` section. For a private repository you will need the `repo` scope and for a public repository you will need the `public_repo` scope. Then it is recommended to save this token on wercker as a protected environment variable.

## Contribution

1. Fork ([https://github.com/tcnksm/dockerfile-gox/fork](https://github.com/tcnksm/dockerfile-gox/fork))
1. Create a feature branch
1. Commit your changes
1. Rebase your local changes against the master branch
1. Push it to your remote repository
1. Create new Pull Request

## Author

[Taich Nakashima](https://github.com/tcnksm)
