# jenkins.clusters.zjusct.io

[无盘系统 CI/CD：Jenkins - ZJUSCT OpenDocs](https://zjusct.pages.zjusct.io/opendocs/operation/system/diskless/auto/)

本仓库是 ZJUSCT 无盘系统 CI/CD 平台（Jenkins）的配置文件。

This repository contains the configuration files for the ZJUSCT diskless system CI/CD platform (Jenkins).

## Usage

```bash
./chroot-installation.sh <DISTRO> [RELEASE]
```

`DISTRO` must match the name in `/etc/os-release`. Refer to [which-distro/os-release: A collection of /etc/os-release from various distros.](https://github.com/which-distro/os-release)

| Distribution | Supported Releases |
| ------------ | ------------------- |
| [debian](https://www.debian.org/releases/) | `stable`, `testing` |
| [ubuntu](https://releases.ubuntu.com/) | `oracular`(latest), `noble`(LTS) |
| [arch](https://archlinux.org/download/) | latest |
| [openEuler](https://openeuler.org/en/download.html) | `24.09`(latest), `24.03`(LTS) |

## Design

Our goal is to implement a **unified system build process**, so that the built systems are as consistent as possible in terms of **functionality and software environment**. That is, the build process is fixed, and each step in the process is customized for each distribution, rather than designing a separate process and configuration for each distribution.

- `make_rootfs`
- `execute_module`: modularized build steps, including software installation, configuration, etc.

These steps usually require chroot environment. Depending on the environment where the script is executed, two methods are supported:

- `chroot`: If running inside docker, use simple `chroot` because docker has provided some isolation.
- `systemd`: If running on the host, use `systemd-nspawn` to create a more isolated environment.

We now determine the environment based on PID 1. If PID 1 is:

- `tini`: We are in docker. Jenkins docker now use this, but can't tell if it's a docker container
- `systemd`: We are on the host running systemd.

## Coding Style

This repository mainly contains Shell scripts, so please follow the following coding style:

- Use the EditorConfig plugin, or view the `.editorconfig` file yourself. Shell Script uses Tab indentation.
- Use the [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) plugin to check if the Shell script is compliant.

## Ignored Files

The following files are ignored because they contain sensitive information and need to be created manually when used. An `.template` file is provided as a template.

| File | Description |
| ---- | ----------- |
| `jenkins/jenkins_jobs.ini` | Jenkins Job Builder configuration file, including the address, username, and password of the Jenkins server. |
| `jenkins/.env` | Docker Compose environment variable file, including the Token required for Jenkins to run. |

## Thanks

- [jenkins.debian.net](https://salsa.debian.org/qa/jenkins.debian.net)
- [emnify/jenkins-casc-docker](https://github.com/emnify/jenkins-casc-docker)
