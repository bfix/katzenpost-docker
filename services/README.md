# Running Katzenpost services in Docker containers

Dockerfiles and helper scripts for building and running
[Katzenpost](https://katzenpost.network/) servers and services
in Docker containers.

## License

Copyright (c) 2025-present, Bernd Fix. All rights reserved.

katzenpost-docker is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

katzenpost-docker is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

SPDX-License-Identifier: AGPL3.0-or-later

## Prerequisites

* Read at least the
[Admin guide](https://katzenpost.network/docs/admin_guide/)
to learn about setting up Katzenpost servers.

* Request access to the `namenlos` git repo if you want to run servers
on the real network.

## Mix server

```bash
cd mix
```

### Customizing the the mix service parameters

You can customize the service parameters at the beginning of `service.sh`:

```bash
NAME=katzenpost/mix
CNT=kp-mix
LISTEN=${2:-0.0.0.0:18181}
```

* `NAME` is the name of the generated Docker image
* `CNT` is the name for the running container
* `LISTEN` is the bind address the service will listen at

### Preparing the host filesystem

```bash
./service.sh prep
```

### Building the Docker image

```bash
./service.sh build [version]
```

You can add a specific version number like `v0.0.67` as a second argument
to build the image based on that version. If not specified it will use
tip of the main branch.

### Create a configuration file for the Mix server

You need to follow the instructions in the Katzenpost
[Admin guide](https://katzenpost.network/docs/admin_guide/) on how to
create a configuration file. You also need access to the `namenlos` repo.

Create a new file named `<yourname>-pq-mixserver.toml` in
`<namenlos.repo>/configs/SSOT/mixes` based the following template.
Change `Identifier` (the server name) and the IP/port setting in
`Addresses` based on your needs. If you need logging, set a path for `File`
in the `[Logging]` section and specify a suitable log level (`DEBUG`,`INFO`,...).

```toml
[Server]
Identifier = "<yourname>"
PKISignatureScheme = "Ed25519 Sphincs+"
WireKEM = "KYBER768-X25519"
Addresses = [ "tcp://<public-ip>:<port>" ]
BindAddresses = [ "tcp://0.0.0.0:8181" ]
DataDir = "/var/lib/katzenpost"
IsGatewayNode = false
IsServiceNode = false

[Logging]
Disable = false
File = ""
Level = "NOTICE"
```

In the `namenlos` repo, change into the `configs` directory and run `make`.
Copy the generated configuration file
`<namelos.repo>/configs/<yourname>-pq-mixserver.toml` to `conf/mix.toml`
in this repo.

### Generating and extracting keys for the mix node

Run the server to generate the keys:

```bash
./service.sh genkeys
```

Check that keys (`*.pem`) have been created in the `data/` directory and
copy the public identity key `data/identity.public.pem` to the
`namenlos` repo as
`<namelos.repo>/keys/mixserver-keys/<yourname>_mix_id_pub_key.pem`.

### Update the 'namenlos' repo

```bash
cd <namenlos.repo>/configs
make
git commit -a
git push
```

Ask a Katzenpost maintainer to add your mix to the mixnet topology.
Your Mix node will be added to the live network as soon as directory
authority servers will refresh their configuration to include your mix.

### Starting/stopping the mix server

```bash
./service.sh start [ListenAddr]
./service.sh stop
```

If you do not specify a `ListenAddr` it will default to `0.0.0.0:18181`. Make sure
the listening port matches the value in the `Addresses` configuration.

Starting the server will begin to show the log output from the running service;
you can terminate it with `^C` any time. This will only terminate the log
output but not the service itself. Run `./service.sh stop` to stop the service.

**N.B.**: If you enable debugging in the configuration, no log output is shown.
Terminate with `^C` and run `tail -f <path-to-logfile>` to show the log.

## Directory Authority server

```bash
cd authority
```

### Customizing the the dirauth service parameters

You can customize the service parameters at the beginning of `service.sh`:

```bash
NAME=katzenpost/authority
CNT=kp-dirauth
LISTEN=${2:-0.0.0.0:28181}
```

* `NAME` is the name of the generated Docker image
* `CNT` is the name for the running container
* `LISTEN` is the bind address the service will listen at

### Preparing the host filesystem for dirauth

```bash
./service.sh prep
```

### Building the Docker image for dirauth

```bash
./service.sh build [version]
```

You can add a specific version number like `v0.0.67` as a second argument
to build the image based on that version. If not specified it will use
tip of the main branch.

### Create a configuration file for the DirAuth server

You need to follow the instructions in the Katzenpost
[Admin guide](https://katzenpost.network/docs/admin_guide/) on how to
create a configuration file. You also need access to the `namenlos` repo.

Create a new file named `<yourname>-pq-authority.toml` in
`<namenlos.repo>/configs/SSOT/authority_configs` based the following template.
Change `Identifier` (the server name) and the IP/port setting in
`Addresses` based on your needs. If you need logging, set a path for `File`
in the `[Logging]` section and specify a suitable log level (`DEBUG`,`INFO`,...).

```toml
[Server]
Identifier = "<yourname>"
PKISignatureScheme = "Ed25519 Sphincs+"
WireKEM = "KYBER768-X25519"
Addresses = [ "tcp://<public-ip>:<port>" ]
BindAddresses = [ "tcp://0.0.0.0:8181" ]
DataDir = "/var/lib/katzenpost"

[Logging]
Disable = false
File = ""
Level = "NOTICE"
```

Create a new file named `<yourname>` in `<namenlos.repo>/configs/SSOT/authorities`
based the following template. Again change `Identifier` (the server name) and
the IP/port setting in `Addresses` based on your needs; they should match the
settings in the previous file.

```toml
Identifier = "<yourname>"
PKISignatureScheme = "Ed25519 Sphincs+"
WireKEMScheme = "KYBER768-X25519"
Addresses = ["tcp://<public-ip>:<port>"]
BindAddresses = ["tcp://0.0.0.0:8181"]
IdentityPublicKey = ""
LinkPublicKey = ""
```

In the `namenlos` repo, change into the `configs` directory and run `make`.
Copy the generated configuration file
`<namelos.repo>/configs/<yourname>-pq-authority.toml` to
`conf/authority.toml` in this repo.

### Generating and extracting keys for dirauth

Run the server to generate the keys:

```bash
./service.sh genkeys
```

Check that keys (`*.pem`) have been created in the `data/` directory.
Insert the public identity key and the public link key into the empty
slots in `<namenlos.repo>/configs/SSOT/authorities/<yourname>`.

### Update the 'namenlos' repo for dirauth

```bash
cd <namenlos.repo>/configs
make
git commit -a
git push
```

Your DirAuth node will be added to the live network as soon as the other
directory authority servers will refresh their configuration.

### Starting/stopping the dirauth server

```bash
./service.sh start [ListenAddr]
./service.sh stop
```

If you do not specify a `ListenAddr` it will default to `0.0.0.0:28181`. Make sure
the listening port matches the value in the `Addresses` configuration.

Starting the server will begin to show the log output from the running service;
you can terminate it with `^C` any time. This will only terminate the log
output but not the service itself. Run `./service.sh stop` to stop the service.

**N.B.**: If you enable debugging in the configuration, no log output is shown.
Terminate with `^C` and run `tail -f <path-to-logfile>` to show the log.
