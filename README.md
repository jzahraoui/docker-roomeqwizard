# Docker RoomEQWizard

## Maintained by: [Sangoku](https://github.com/jzahraoui/docker-roomeqwizard)

A Docker container for running RoomEQWizard (REW), an audio measurement and analysis tool.
The container start the API headless on the port 4735.

## Description

This project provides a containerized version of RoomEQWizard, making it easy to run REW in a Docker environment.

RoomEQWizard is a java application used for room acoustics analysis, loudspeaker measurement, and equalization.

## Features

- Containerized RoomEQWizard application
- Easy setup and deployment

## Prerequisites

- Docker installed on your system

## Installation

- Clone this repository:

  ```bash
  git clone git@github.com:jzahraoui/docker-roomeqwizard.git
  cd docker-roomeqwizard
  ```

- Build the Docker image:

  ```bash
  docker build -t roomeqwizard .
  ```

## Usage

To run RoomEQWizard in a container:

```bash
docker run -d \
  --name roomeqwizard \
  -p 4735:4735 \
  jaoued/roomeqwizard
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Under GNU AFFERO GENERAL PUBLIC LICENSE

## Acknowledgments

RoomEQWizard - <https://www.roomeqwizard.com/>
