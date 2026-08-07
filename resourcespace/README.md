# ResourceSpace Installer

This project contains a Bash script that automates the installation and initial setup of ResourceSpace on a Ubuntu Linux server.

The primary goal of this project is to practice Bash scripting by automating a real-world application installation instead of performing each step manually. Throughout its development, the script has been continuously improved by adding better error handling, validation, logging, modular functions, and command-line options.

## Features

* Automated ResourceSpace installation
* Package dependency checks
* Service configuration
* Database configuration
* PHP configuration
* Apache web server configuration
* Logging and status messages
* Error handling
* Command-line argument support
* Idempotent installation checks where applicable

## Learning Objectives

This project helped me understand:

* Writing modular Bash scripts
* Function-based script design
* Command-line argument parsing
* Linux package management
* Apache configuration
* PHP configuration
* MariaDB/MySQL setup
* Error handling and exit codes
* Logging and debugging
* Automating repetitive administration tasks

## Requirements

* Linux
* Bash
* Apache
* PHP
* MariaDB/MySQL
* Internet connection for package installation

## Usage

```bash
chmod +x resourcespace_installer.sh
./resourcespace_installer.sh
```

Refer to the script help output for additional command-line options.

## About This Project

This project is part of my Linux learning journey. It represents my effort to understand how production-style installation scripts are designed and implemented using Bash.

Rather than simply installing ResourceSpace manually, I chose to automate the entire process to strengthen my Linux administration, Bash scripting, and automation skills. As I continue learning, this script will be improved with better validation, additional features, and cleaner code.
