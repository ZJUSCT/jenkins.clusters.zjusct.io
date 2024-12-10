# jenkins.clusters.zjusct.io

[无盘系统 CI/CD：Jenkins - ZJUSCT OpenDocs](https://zjusct.pages.zjusct.io/opendocs/operation/system/diskless/auto/)

本仓库是 ZJUSCT 无盘系统 CI/CD 平台（Jenkins）的配置文件。

This repository contains the configuration files for the ZJUSCT diskless system CI/CD platform (Jenkins).

## TODO

- [ ] Package system image from built rootfs

## Usage

```bash
./chroot-installation.sh <DISTRO> [RELEASE]
```

`DISTRO` must match the name in `/etc/os-release`. Refer to [which-distro/os-release: A collection of /etc/os-release from various distros.](https://github.com/which-distro/os-release)

## Design

Our goal is to implement a **unified system build process**, so that the built systems are as consistent as possible in terms of **functionality and software environment**. That is, the build process is fixed, and each step in the process is customized for each distribution, rather than designing a separate process and configuration for each distribution.

- `make_rootfs`
- `exec_modules`: modularized build steps, including software installation, configuration, etc. These functions are named `module_*_$DISTRO`.
    - `bootstrap`: basic system configuration
    - `software`: software installation

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
