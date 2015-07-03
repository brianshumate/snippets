# Docker

[Docker](https://www.docker.com/) is "an open platform for distributed 
applications for developers and sysadmins", and also a great container 
solution.

## boot2docker

Here are some snippets which are handy when running Docker with Mac OS X
using [boot2docker](https://github.com/boot2docker/boot2docker).

## X Applications with Forwarded Display

```
brew install socat
brew cask install xquartz
open -a XQuartz
```

Then:

```
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
```

In another term:

```
docker run -e DISPLAY=192.168.59.3:0 jess/geary
```

Note that DISPLAY IP address should be that of your host machine's 
`vboxnet0` device, i.e. the output of `ifconfig vboxnet0`.

## Resources

0. [Docker Containers on the Desktop](https://blog.jessfraz.com/post/docker-containers-on-the-desktop/) is an excellent resource for running desktop applications as Docker containers
1. [Docker](https://www.docker.com/)
2. [Docker documentation](https://docs.docker.com/)
3. [boot2docker](https://github.com/boot2docker/boot2docker)
