# Running Katzenpost in Docker containers

Dockerfiles and helper scripts for building and running
[Katzenpost](https://katzenpost.network/) servers, services and clients
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

## Intro

The [Katzenpost project](https://katzenpost.network/) implements a post-quantum
mix network to provide anonymous data transfer between users and services. Unlike
the [Tor network](https://torproject.org) - which is considered "gold standard"
for anonymity on the internet - Katzenpost aimes to
*protect your communication against a global passive adversary* (GPA) not just some random
eavesdropper with limited capabilities. Even an adversary with a huge quantum computer
would not be able to read the content of the exchanged data because Katzenpost is
using a (hybrid) post-quantum scheme for encryption and signatures.

This comes at a cost: To combat traffic/timing correlation attacks (a technique that
a GPA can use to de-anonymize Tor users) a higher latency (network delay) is required.
This make Katzenpost likely unsuitable for real-time data exchange but perfect for chat
or email/file exchange where a 'delay' between sending and receiving a message is not
critical or not too annoying. Katzenpost has its own chat client that users can use to
participate anonymously in individual or group chats. It uses some new techniques to
make sure that the anonymity guarantees of Katzenpost are held - including a formal
proof of the protocol used.

This repo provides Docker images to run Katzenpost clients (like chat) or services
(mixnet nodes) in Docker containers.

## Using the Katzenpost chat

If you only want to use the Katzenpost chat client, please read the
[client documentation](clients/README.md) for a description.

## Running Katzenpost services

If you want to support the Katzenpost infrastructure by running Katzenpost mixnet nodes
on a your own servers, you are encouraged to contact the Katzenpost team first. New
nodes need to be manually integrated into the network topology after review (and depending
on need), so discussing with them what type of nodes would be helpful can save a lot of
time.

There are different types of nodes (like in the Tor network):

* **Directrory Authorities** negotiate a consensus between themselves about the current
state of the network and distribute this consensus to other nodes. A consensus is
authorative for all nodes.

* **Mixes** are the work horses of the network; they mix the actual user traffic to
provide anonymity. A high-bandwith network connection is mandatory for mixes.

* **Gateways** are the interface between clients on the internet and the Katzenpost
network. A high-bandwith network connection is also mandatory for gateways.

* **Services** can implement custom services reachable over the Katzenpost network.

While the above services have a counterparts in the Tor network (DirAuth, Node,
Guards/Exits, Hidden Services), Katzenpost uses additional services:

* **Couriers** are used to handle message exchange between clients that are not 'online'
at the same time. Currently only used by the Katzenpost chat.

* **Storage nodes** are used by couriers to store messages for asynchronous exchange.

Find more information about these node types in the
[Katzenpost documentation](https://katzenpost.network/docs/).

To build and run Docker images for these services, please read the
[service documentation](services/README.md).
