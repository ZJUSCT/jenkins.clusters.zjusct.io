#!/bin/bash

apt-get install sssd-ldap libsss-sudo openssh-server sssd-tools ldap-utils
curl https://gitlab.star-home.top:4430/star/deploy-ldap/-/raw/main/linux_"$ARCH" -o /bin/goldaptools
chmod +x /bin/goldaptools
chmod u+s /bin/goldaptools
ln -s /bin/goldaptools /bin/pubkey
ln -s /bin/goldaptools /bin/goldaptools_ssh_withcheck

cat >/etc/sssd/sssd.conf <<EOF
[sssd]
domains = LDAP
config_file_version = 2

[nss]

[pam]

[domain/LDAP]

id_provider = ldap
ldap_uri = ldaps://172.25.2.253

ldap_tls_cacert = /etc/sssd/ca.crt
ldap_tls_reqcert = allow

ldap_default_bind_dn = cn=readonly,dc=zjusct,dc=io
ldap_default_authtok = readonly

ldap_search_base = dc=zjusct,dc=io
ldap_group_search_base = ou=Groups,dc=zjusct,dc=io
ldap_sudo_search_base = ou=sudoers,ou=Config,dc=zjusct,dc=io
EOF
chmod 600 /etc/sssd/sssd.conf
cat >/etc/sssd/ca.crt <<EOF
-----BEGIN CERTIFICATE-----
MIID2zCCAsOgAwIBAgIUJ312aSIgWY/7zjPAf5qDhoSsks0wDQYJKoZIhvcNAQEL
BQAwfTELMAkGA1UEBhMCQ04xDzANBgNVBAgMBlV0b3BpYTEZMBcGA1UEBwwQTG90
dXMgTGFuZCBTdG9yeTEPMA0GA1UECgwGWkpVU0NUMRIwEAYDVQQDDAl6anVzY3Qu
aW8xHTAbBgkqhkiG9w0BCQEWDm1haWxAemp1c2N0LmlvMB4XDTI0MDQyOTAyMzEz
MloXDTI5MDQyODAyMzEzMlowfTELMAkGA1UEBhMCQ04xDzANBgNVBAgMBlV0b3Bp
YTEZMBcGA1UEBwwQTG90dXMgTGFuZCBTdG9yeTEPMA0GA1UECgwGWkpVU0NUMRIw
EAYDVQQDDAl6anVzY3QuaW8xHTAbBgkqhkiG9w0BCQEWDm1haWxAemp1c2N0Lmlv
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApRD8Dpib9yLF0qEzHh7u
OmIYmv06fgbHN3oyKYlWKMeTs4if7hJ3wwnHa2k6HaBKbLGgG/7I/VCtPHufw84H
89ssv3Yu0TESd0YJ7QXjqKPzyf8qaPzcHr2EdWaza3dB6TaF1U4UlmseUkp3Pl8m
j++d2jKLtEFaOABmNyMZxvKqYY6e5sDpFXEo0fpr5jEKA/W/KBNQ+YsORsjuAELA
9t9I3K9T9j4bLmJad9f128HbgBp04rWpIoXhEXFa5+qV1Yc2AJlkDx+oQxnt+i7F
nDC4908mVfMf6hnPNVah6fBiQoXmAqfuiOIYdPJUGvCfKeIG8LW1UbgvMyLsmh05
rQIDAQABo1MwUTAdBgNVHQ4EFgQUQIqpcISo8MDAjh1j/pWg213uoIUwHwYDVR0j
BBgwFoAUQIqpcISo8MDAjh1j/pWg213uoIUwDwYDVR0TAQH/BAUwAwEB/zANBgkq
hkiG9w0BAQsFAAOCAQEATwRPgsLUTgPOaMGZ86qRfaQVOj9Q6/VisyAhRGiKJblX
02KnqmeORNPfmpZCCqa1O7TqHLUciB8plgXPpCHH5NF/IiKCSayLl4D9DN12Kcvt
CBaK2dpWWJN2EdyT4ehUdKxOkDCQog+kqdZ1BmRz4q6dA9jdVDHBBVJzCRR5cjhJ
u346r0OmH6N+xJ+c2L692mPPwPprD4edM2w8smqE3KutNFat8MuIsufcd1m7qWce
Df4bQRNQr+tE0EDU9WXw1YD/WSvDdeTgLYAFSJMxMobvIVM1y/Qg/nGpFwiVwmQ3
Ynw35HjwG8Uh3Zjhl1EOcfKNSNi0tDCOpdMbIpWwBA==
-----END CERTIFICATE-----
EOF
cat >>/etc/ssh/sshd_config <<EOF
PasswordAuthentication no
AuthorizedKeysCommandUser nobody
AuthorizedKeysCommand /bin/goldaptools_ssh_withcheck
EOF

mkdir -p /etc/systemd/system/sssd.service.d
mkdir -p /etc/systemd/system/sssd-nss.service.d
mkdir -p /etc/systemd/system/sssd-pam.service.d
tee /etc/systemd/system/sssd.service.d/override.conf /etc/systemd/system/sssd-nss.service.d/override.conf /etc/systemd/system/sssd-pam.service.d/override.conf <<EOF
[Service]
Environment=DEBUG_LOGGER=--logger=journald
EOF
