# Docker RoomEQWizard

Container image for running Room EQ Wizard (REW) in headless API mode.

This project packages REW inside Docker, starts a virtual X server with Xvfb, and launches REW with its HTTP API exposed on port 4735. It is intended for automation, remote workflows, and integrations that need REW without opening the desktop GUI.

Maintained by [Sangoku](https://github.com/jzahraoui/docker-roomeqwizard).

## What This Project Does

Room EQ Wizard is a Java application used for room acoustics analysis, loudspeaker measurement, and equalization.

This repository provides a Docker image that:

- runs REW in API mode
- starts REW without a visible GUI
- exposes the REW API on port 4735
- can optionally access host audio devices through ALSA
- can be built and published for multiple architectures

## What This Project Is Not

This image is not a desktop distribution of REW.

- It does not provide a local graphical interface.
- It does not include a browser UI or VNC frontend.
- It is designed primarily for headless and scripted usage.

## Features

- Headless REW startup using Xvfb
- REW API exposed on port 4735
- Optional passthrough for host audio devices
- Docker Hub image available as `jaoued/roomeqwizard`
- Multi-architecture build pipeline for `linux/amd64` and `linux/arm64`
- Built-in health check against the REW API endpoint

## Prerequisites

- Docker installed on the host
- Docker Compose if you want to use Compose
- Linux audio device access if you want REW to enumerate input devices from the host

## Quick Start

Pull and start the published image:

```bash
docker run -d \
  --name roomeqwizard \
  -p 4735:4735 \
  jaoued/roomeqwizard:latest
```

Check that the container is running:

```bash
docker ps
docker logs roomeqwizard
```

Verify that the REW API responds:

```bash
curl http://localhost:4735/
```

If you want to expose the container on a different host port, remap it on the left side:

```bash
docker run -d \
  --name roomeqwizard \
  -p 8080:4735 \
  jaoued/roomeqwizard:latest
```

## When To Use Audio Device Passthrough

If you only need the REW API for headless automation, the basic container is enough.

If you want REW to see host sound devices, add ALSA device access:

```bash
docker run -d \
  --name roomeqwizard \
  -p 4735:4735 \
  --device /dev/snd:/dev/snd \
  --group-add audio \
  jaoued/roomeqwizard:latest
```

This is mainly useful on Linux hosts where `/dev/snd` is available.

## Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  roomeqwizard:
    image: jaoued/roomeqwizard:latest
    container_name: roomeqwizard
    ports:
      - '4735:4735'
```

Start the service:

```bash
docker compose up -d
```

If you need host audio devices:

```yaml
services:
  roomeqwizard:
    image: jaoued/roomeqwizard:latest
    container_name: roomeqwizard
    ports:
      - '4735:4735'
    devices:
      - '/dev/snd:/dev/snd'
    group_add:
      - 'audio'
```

## Build Locally

Clone the repository and build the image locally:

```bash
git clone git@github.com:jzahraoui/docker-roomeqwizard.git
cd docker-roomeqwizard
docker build -t roomeqwizard .
```

You may want to build locally if you need to:

- test changes to the image
- pin or change the bundled REW version
- customize the bundled configuration files

The Dockerfile supports a build argument for the REW version:

```bash
docker build \
  --build-arg REW_VERSION=5_40_beta_119 \
  -t roomeqwizard .
```

## Runtime Details

At startup, the container:

1. starts Xvfb
2. launches REW with `-api -nogui`
3. binds the REW API to `0.0.0.0:4735`

This makes the service reachable from outside the container once the port is published.

## CI and Publishing

GitHub Actions builds and tests the image for `linux/amd64` and `linux/arm64`, then publishes the multi-architecture image to Docker Hub.

The workflow also validates that the container answers on port 4735 before publishing.

## Contributing

1. Fork the repository.
2. Create a branch for your change.
3. Build and test the image locally.
4. Open a pull request with a clear description.

## License

Distributed under the GNU Affero General Public License.

## Acknowledgments

Room EQ Wizard: <https://www.roomeqwizard.com/>
