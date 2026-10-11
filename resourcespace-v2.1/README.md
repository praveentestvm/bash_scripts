# ResourceSpace Installer v2.1

A Bash scripting project to automate the installation of ResourceSpace on Ubuntu Linux.

**Author:** Praveen  
**Language:** Bash  
**Platform:** Ubuntu Linux

## About This Project

This project started as a way for me to practise Bash scripting and learn more about Linux system administration.

My initial goal was to write a script that could automate the ResourceSpace installation process. As I continued working on it, I started learning more about functions, argument handling, error handling, and other Bash concepts.

In version 2.1, I've redesigned the installer to use a modular structure instead of keeping most of the code in a single script.

I'm still learning, and this project is one of the ways I'm trying to improve my scripting skills through practical work.

## What Gave Me This Idea?

While learning Linux, I started exploring larger projects, such as the Linux kernel and other Linux tools, to understand how their code is organized.

I noticed that large projects contain many files and directories rather than keeping all their code in one place.

This got me thinking: **Why couldn't I try something similar with my own Bash installer?**

My earlier installer was mostly a single script. I wanted to experiment with splitting the code into separate files and organizing related tasks together.

I know my project is nowhere near the size or complexity of the Linux kernel. I simply wanted to learn from the way larger projects organize their code and try applying some of those ideas to my own project.

This is my first attempt at redesigning the installer in this way, and I still have a lot to learn.

## My Earlier Installer

The original version of my ResourceSpace installer was written as a single Bash script. At that stage, keeping everything in one file helped me understand the installation process and develop my scripting skills.

You can view my original implementation here:

[View the original monolithic installer — resourcespace_installer.sh](https://github.com/praveentestvm/bash_scripts/blob/main/resourcespace/resourcespace_installer.sh)

I've kept the original script in the repository so that anyone interested can look at the code and compare it with the new version.

## What's Different in v2.1?

In version 2.1, I've started splitting the installer into separate files and modules.

Instead of keeping most of the functionality in one script, I'm trying to organize related tasks into different components.

My aim is to make the code easier to read, understand, and maintain. I also want to learn how to manage a Bash project as it grows.

| Earlier Version | Version 2.1 |
|---|---|
| Most of the code was in one script. | The code is split into multiple files. |
| Most tasks were handled within the main script. | Different tasks are organized into separate modules. |
| Changes were made mainly in one file. | Changes can be made in the relevant modules. |

The main difference is how the code is organized. You can compare the two versions to see what I've changed.

I'm still learning whether my new approach is the best way to organize the code, and I expect to make improvements as I gain more experience.

## Requirements

- Ubuntu Linux 24.04
- Bash and the standard Linux utilities used by the installer
- Sufficient privileges to install packages and configure system services
- An internet connection to download packages and application files

The installer also sets up or configures the software required by ResourceSpace, including Apache, PHP, and a compatible database server.

The exact requirements depend on the installation process implemented in this version.

## Installation and Usage

### 1. Clone the Repository

```bash
git clone https://github.com/praveentestvm/bash_scripts.git
```

### 2. Navigate to the Installer

```bash
cd bash_scripts/resourcespace-v2.1/
```

### 3. Run the Installer

```bash
sudo ./install.sh
```

Review the script before running it, especially if you're using it on a system that contains important data.

## Testing

**Test environment:** Ubuntu 24.04

I'm using Ubuntu 24.04 to test the installer and check how it behaves.

I'll continue testing the different operations and updating this section as I discover problems or make improvements.

## What I Want to Improve

There are still things I'd like to improve as I continue learning Bash scripting.

Some of my goals are to improve error handling, test more failure scenarios, make the code easier to maintain, and understand how to recover when an installation fails.

I also want to get better at writing scripts that are easier to troubleshoot and safer to run.

These are learning goals, and I'll work on them as I continue developing the project.

## Final Thoughts

This project is part of my journey in learning Bash scripting and Linux administration.

I started with a single script and have now tried reorganizing it into separate modules. The redesign has given me an opportunity to learn more about code organization and how different parts of a Bash project can work together.

I don't consider this a perfect installer. My aim is to keep learning, improve the code, and understand what I could have done better.

If you notice something that could be improved, suggestions and feedback are welcome.

## Author

**Praveen**

GitHub: [@praveentestvm](https://github.com/praveentestvm)

Repository: [bash_scripts](https://github.com/praveentestvm/bash_scripts)