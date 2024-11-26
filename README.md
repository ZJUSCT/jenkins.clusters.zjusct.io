# jenkins.clusters.zjusct.io

[无盘系统 CI/CD：Jenkins - ZJUSCT OpenDocs](https://zjusct.pages.zjusct.io/opendocs/operation/system/diskless/auto/)

本仓库是 ZJUSCT 无盘系统 CI/CD 平台（Jenkins）的配置文件。

## Ignored Files

下面的文件因为包含敏感信息而被忽略，使用时需要手动创建：

| File | Description |
| ---- | ----------- |
| `jenkins/jenkins_jobs.ini` | Jenkins Job Builder 配置文件，包含 Jenkins 服务器的地址、用户名和密码等信息。 |
| `jenkins/.env` | Docker Compose 环境变量文件，包含 Jenkins 运行所需的 Token 等信息。 |

## Thanks

- [jenkins.debian.net](https://salsa.debian.org/qa/jenkins.debian.net)
- [emnify/jenkins-casc-docker](https://github.com/emnify/jenkins-casc-docker)
