# Running Katzenpost clients in Docker containers

Dockerfiles and helper scripts for building and running
[Katzenpost](https://katzenpost.network/) clients in Docker containers.

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

## Client daemon (kpclientd)

To use the Katzenpost network from client applications you first need to run
a local daemon. The daemon handles the communication with the Katzenpost
network on behalf of client applications. Clients use Unix sockets or TCP
ports to talk to the daemon.

```bash
cd kpclientd
```

### Building the client daemon

```bash
./service.sh build [version]
```

You can add a specific version number like `v0.0.67` as a second argument to
the build script. If not specified, tip of the main branch will be used.

If the above build fails, you should run the build steps separately to identify
the problem:

```bash
./service.sh prep             # Preparing the host filesystem
./service.sh image [version]  # Building the Docker image
./service.sh config           # Creating configuration file
```

### Logging the client daemon

If you need debugging info from a log file, you can change the following section
in the configuration file `conf/client.toml` to enable logging:

```bash
[Logging]
  Disable = false
  File = "/var/log/katzenpost/kpclient.log"
  Level = "DEBUG"
```

**N.B.**: Do **NOT** change anything else in the configuration file!

### Starting/stopping the daemon

```bash
./service.sh (start|stop)
```

Starting kpclientd will begin to show the log output from the running service;
you can terminate it with `^C` any time. This will only terminate the log
output but not the service itself. Run `./service.sh stop` to stop the service.

To follow the log output again use:

```bash
./service.sh logs
```

**N.B.**: If you enable debugging in the configuration, no log output is shown.
After starting the service, terminate with `^C` and run `tail -f <path-to-logfile>`
to show the log.

## KatzenQt chat application

The KatzenQt chat application enables encrypted group chats over the Katzenpost
mixnet. It is currently the only client application available for Katzenpost.

```bash
cd katzenqt
```

### Building the KatzenQt client

```bash
./client.sh build [version]
```

If the above build fails, you should run the build steps separately to identify
the problem:

```bash
./client.sh prep             # Preparing the host filesystem
./client.sh image [version]  # Building the Docker image
./client.sh config           # Creating configuration file
```

### Running KatzenQt

**N.B.:** KatzenQt uses Qt6, and using Qt6 within Docker can result in problems
on certain Nvidia graphic cards. The window for KatzenQt might show up and the
controls in the systray look and work fine, but no widgets are drawn in the
window. If you encounter this problem and can solve the issues for your Nvidia
card, please give a feedback to `ops@cryptonymity.net`.

#### ...in foreground

```bash
./client.sh run
```

Starting katzenqt will begin to show the log output from the running service.
If you terminate the output with `^C`, it will also terminate the client.

#### ... in background

```bash
./client.sh start
```

Behaves like the foreground mode, but terminating the log output does not
terminate the client. If you want to continue show log out (again), use:

```bash
./client.sh logs
```

To stop the client, run

```bash
./client.sh stop
```
