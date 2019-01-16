Forward GNUPG agent socket into a container

Based on https://github.com/uber-common/docker-ssh-agent-forward

Still experimental -- contact antoine@lunar-ocean.com if you want help.


## Installation

Assuming you have a `/usr/local`

```
$ git clone git://github.com/tmio/gpg-agent-forward
$ cd gpg-agent-forward
$ make
$ make install
```

On every boot, do:

```
pinata-gpg-forward
```

and the you can add `-v /gpg-agent:/path/to/.gnupg/` to your docker CLI command to
mount the GNUPG home directory into your container:

```
$ docker run -it -v /gnupg:/root/.gnupg tmio/gpg-agent-forward gpg -a -s
foo
-----BEGIN PGP MESSAGE-----
...
```

To fetch the latest image, do:

```
pinata-gpg-pull
```

## Running as non-root

If you want to use the GNUPG home dir in a container as a non-root user you
need to first fix permissions (assuming 1000 is your user id):

```
docker exec pinata-gpg-agent chown -R 1000:1000 /gpg-agent
docker exec pinata-gpg-agent chmod -R 700 /gpg-agent
```

## Developing

To build an image yourself rather than fetching from Docker Hub, run
`./pinata-gpg-build.sh` from your clone of this repo.

We didn't bother installing the build script with the Makefile since using the
hub image should be the common case.


## Contributors

* Justin Cormack
* https://github.com/uber-common/docker-ssh-agent-forward/graphs/contributors
* https://github.com/transifex/docker-gpg-forward/graphs/contributors
* https://github.com/tmio/docker-gpg-forward/graphs/contributors

[License](LICENSE.md) is ISC.
