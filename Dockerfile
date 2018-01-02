FROM cloudfoundry/cflinuxfs2

ENV LANG C.UTF-8

# dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && yes | add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3.5 python3.5-dev python3.6 python3.6-dev \
    && yes | add-apt-repository ppa:webupd8team/java \
    && apt-get update && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && apt-get install -y --no-install-recommends oracle-java8-installer \
    && rm -rf /var/lib/apt/lists/*

#
RUN set -ex; \
  \
  wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
  \
  python3.5 get-pip.py \
    --disable-pip-version-check \
    --no-cache-dir; \
  pip3.5 --version; \
  \
  pip3.5 install numpy --upgrade; \
  python3.6 get-pip.py \
    --disable-pip-version-check \
    --no-cache-dir; \
  pip3.6 --version; \
  \
  pip3.6 install numpy --upgrade; \
  rm -f get-pip.py

#
RUN set -ex; \
  \
  wget -O bazel-0.8.1-without-jdk-installer-linux-x86_64.sh 'https://github.com/bazelbuild/bazel/releases/download/0.8.1/bazel-0.8.1-without-jdk-installer-linux-x86_64.sh'; \
  \
  chmod +x ./bazel-0.8.1-without-jdk-installer-linux-x86_64.sh && ./bazel-0.8.1-without-jdk-installer-linux-x86_64.sh; \
  \
  rm -f bazel-0.8.1-without-jdk-installer-linux-x86_64.sh
