# jenkins.clusters.zjusct.io

[无盘系统 CI/CD：Jenkins - ZJUSCT OpenDocs](https://zjusct.pages.zjusct.io/opendocs/operation/system/diskless/auto/)

本仓库是 ZJUSCT 无盘系统 CI/CD 平台（Jenkins）的配置文件。

## TODO

- [ ] 重构，统一各发行版的构建步骤。
- [ ] 放弃多版本维护。Debian 仅保留 stable，Ubuntu 仅保留 LTS。

## Coding Style

本仓库大量使用 Shell 脚本，因此请遵循以下代码风格：

- 使用 EditorConfig 插件，或自行查看 `.editorconfig` 文件。Shell Script 使用 Tab 缩进。
- 使用 [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) 插件检查 Shell 脚本是否符合规范。

## Ignored Files

下面的文件因为包含敏感信息而被忽略，使用时需要手动创建：

| File | Description |
| ---- | ----------- |
| `jenkins/jenkins_jobs.ini` | Jenkins Job Builder 配置文件，包含 Jenkins 服务器的地址、用户名和密码等信息。 |
| `jenkins/.env` | Docker Compose 环境变量文件，包含 Jenkins 运行所需的 Token 等信息。 |

## Thanks

- [jenkins.debian.net](https://salsa.debian.org/qa/jenkins.debian.net)
- [emnify/jenkins-casc-docker](https://github.com/emnify/jenkins-casc-docker)
