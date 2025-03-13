FROM postgres

RUN sed -i 's/deb.debian.org/mirrors.zju.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's/apt.postgresql.org\/pub/mirrors.zju.edu.cn\/postgresql/g' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update

WORKDIR /root

ENV https_proxy=http://172.25.2.253:7890

RUN apt-get install -y git cmake g++ postgresql-server-dev-17 pkg-config
RUN <<EOF
git clone --depth=1 https://github.com/repology/libversion
cd libversion
cmake . && cmake --build . -j
make install
ldconfig
EOF

RUN <<EOF
git clone --depth=1 https://github.com/repology/postgresql-libversion.git
cd postgresql-libversion
make && make install
EOF

SHELL ["/bin/bash", "-c"]

RUN apt-get install -y python3-full python3-pip python3-venv libyajl-dev libpython3-dev
RUN pip config set global.index-url https://mirrors.zju.edu.cn/pypi/web/simple
RUN <<EOF
python3 -m venv repology
source repology/bin/activate
git clone --depth=1 https://github.com/repology/repology-updater
cd repology-updater
pip install -r requirements.txt
pip install -e .
EOF
