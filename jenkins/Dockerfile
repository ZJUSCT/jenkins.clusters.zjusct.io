FROM jenkins/jenkins

# change to root user
USER root

# change the source of apt
# add backports
# and install required packages
RUN . /etc/os-release && cat <<EOF >/etc/apt/sources.list.d/debian.sources
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian
Suites: $VERSION_CODENAME $VERSION_CODENAME-updates $VERSION_CODENAME-backports
Components: main contrib non-free non-free-firmware
EOF

RUN apt-get update \
     && apt-get install -y \
        mmdebstrap \
        ubuntu-keyring \
        rsync \
        dnf rpm
RUN apt-get clean

# # prepare dnf repos
# RUN mkdir -p /etc/yum.repos.d/
# # https://docs.openeuler.org/zh/docs/24.09/docs/Administration/%E4%BD%BF%E7%94%A8DNF%E7%AE%A1%E7%90%86%E8%BD%AF%E4%BB%B6%E5%8C%85.html
# RUN cat <<EOF >/etc/yum.repos.d/openEuler.repo
# [openEuler]
# name=openEuler-$releasever-OS
# baseurl=https://mirrors.zju.edu.cn/openeuler/openEuler-$releasever/OS/$basearch/
# enabled=1
# gpgcheck=1
# gpgkey=https://mirrors.zju.edu.cn/openeuler/openEuler-$releasever/OS/$basearch/RPM-GPG-KEY-openEuler
# EOF

# skip the setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"
# use the mirror of TUNA
# https://github.com/jenkinsci/docker/?tab=readme-ov-file#setting-update-centers
ENV JENKINS_UC https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates
ENV JENKINS_UC_EXPERIMENTAL https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/experimental
ENV JENKINS_UC_DOWNLOAD https://mirrors.tuna.tsinghua.edu.cn/jenkins/
ENV JENKINS_PLUGIN_INFO https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/current/plugin-versions.json
# timezone
ENV TZ="Asia/Shanghai"

# install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --clean-download-directory --list --view-security-warnings -f /usr/share/jenkins/ref/plugins.txt
