<div align="center">

<h1>SSH Tunnel PWSH</h1>

<img src="./docs/banner.png" alt="Project banner" width="100%" />

<br />

Short, clear description of the project in one sentence.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](#license)
[![Status](https://img.shields.io/badge/status-active-success.svg)](#overview)
[![Language](https://img.shields.io/badge/language-PowerShell-blue.svg)](#overview)

<!-- Optional GitHub badges -->
<!-- Replace USERNAME and REPOSITORY -->

[![Release](https://img.shields.io/github/v/release/hadzicni/ssh-tunnel-pwsh)](https://github.com/hadzicni/ssh-tunnel-pwsh/releases)
[![Stars](https://img.shields.io/github/stars/hadzicni/ssh-tunnel-pwsh)](https://github.com/hadzicni/ssh-tunnel-pwsh/stargazers)
[![Issues](https://img.shields.io/github/issues/hadzicni/ssh-tunnel-pwsh)](https://github.com/hadzicni/ssh-tunnel-pwsh/issues)
[![Last Commit](https://img.shields.io/github/last-commit/hadzicni/ssh-tunnel-pwsh)](https://github.com/hadzicni/ssh-tunnel-pwsh/commits)

<br />

[Quick Start](#installation) ·
[Features](#features) ·
[Usage](#usage) ·
[Contributing](#contributing)

</div>

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Development](#development)
- [Build and Deployment](#build-and-deployment)
- [Security](#security)
- [Contributing](#contributing)
- [Maintainers](#maintainers)
- [Contact](#contact)
- [License](#license)

## Overview

This project is a simple SSH tunnel implementation in PowerShell. It allows users to create secure tunnels for remote access to services and applications. The project is designed to be easy to use and configure, making it accessible for both beginners and experienced users.

## Tech Stack

| Category | Technology |
| -------- | ---------- |
| Language | PowerShell |

## Features

- Create SSH tunnels with ease
- Support for local and remote port forwarding
- Configurable options for authentication and connection settings

## Prerequisites

- PowerShell 7.0 or higher
- OpenSSH client installed and configured on the system

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/hadzicni/ssh-tunnel-pwsh.git
cd ssh-tunnel-pwsh
```

### 2. Install dependencies

No dependencies are required for this project.

### 3. Start the project

```bash
.\ssh-tunnel.ps1
```

## Configuration

The project can be configured using the `profiles.json` file. Here are the available options:

```json
{
  "profiles": [
    {
      "name": "Example Profile",
      "host": "example.com",
      "port": 22,
      "username": "user",
      "localPort": 8080,
      "remotePort": 80,
      "privateKeyPath": "C:\\path\\to\\private\\key"
    }
  ]
}
```

## Usage

To create an SSH tunnel, run the `ssh_tunnel.ps1` script and select the desired profile from the list. The script will establish the tunnel based on the configuration provided in the `profiles.json` file.

## Development

Simply edit the `ssh_tunnel.ps1` script and make your changes. You can test your changes by running the script locally.

## Build and Deployment

This project does not require a build process. To deploy, simply copy the `ssh_tunnel.ps1` script and the `profiles.json` configuration file to the target environment.

## Security

If you discover a security vulnerability, please do not open a public issue.

Instead, report it privately:

- Email: nikolahadzic7@icloud.com
- Maintainer: Nikola Hadzic

We will investigate and provide updates as quickly as possible.

### Supported Versions

| Version        | Supported |
| -------------- | --------- |
| Latest         | ✅        |
| Older versions | ❌        |

## Contributing

Contributions are welcome. A possible workflow:

1. Create a fork
2. Create a feature branch
3. Implement your changes
4. Run tests and linting
5. Open a pull request

## Maintainers

<!-- Duplicate the <td> block for additional maintainers -->
<table>
	<tr>
		<td align="center" width="180">
			<a href="https://github.com/hadzicni">
			    <img src="https://github.com/hadzicni.png?size=160" width="96" height="96" alt="Nikola Hadzic" />
			    <br />
			    <strong>Nikola Hadzic</strong>
			</a>
			<br />
			Core maintainer
		</td>
	</tr>
</table>

## Contact

- Contact person: Nikola Hadzic
- Email: nikolahadzic7@icloud.com
- Project page: https://github.com/hadzicni/ssh-tunnel-pwsh

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for details.
