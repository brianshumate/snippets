# Docker Snippets

[Docker](https://www.docker.com/) is "an open platform for distributed
applications for developers and sysadmins", and also a great container
solution.

## Stop and Remove by image name

Note: this needs 1.9 or higher.

```
docker stop $(docker ps -q --filter ancestor=<imagename>)
docker rm $(docker ps -a -q --filter ancestor=<imagename>)
```

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

## Couchbase Server Node

```
docker-machine start docker-host
docker pull couchbase
docker run -d -p 8091:8091 couchbase
```

Configure the node by opening this URL in a browser:

```
http://$DOCKER-MACHINE-IP:8091
```

where `$DOCKER-MACHINE-IP` is the IP address assigned to your docker-machine.

Enable the default bucket.

Create Couchbas Server administrator user account:

- username: *Administrator*
- password: *password*

Start a shell in the Couchbase Server node container:

```
docker exec -it <cid> bash
```

## Resources

1. [Docker](https://www.docker.com/)
2. [Docker documentation](https://docs.docker.com/)
3. [docker-machine](https://docs.docker.com/machine/)
4. [Docker Containers on the Desktop](https://blog.jessfraz.com/post/docker-containers-on-the-desktop/) is an excellent resource for running desktop applications as Docker containers
