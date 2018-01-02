#!/bin/bash -e

TENSORFLOW_REPO="${TENSORFLOW_REPO:-/tmp/tensorflow}"

if [[ -d "${TENSORFLOW_REPO}" ]]; then
  pushd "${TENSORFLOW_REPO}"
    git checkout -f master
    git pull
  popd
else
  git clone https://github.com/tensorflow/tensorflow.git "${TENSORFLOW_REPO}"
fi

_build() {
  bazel clean
  PYTHON_VERSION=$1
  PYTHON_BIN_PATH=$(which "python${PYTHON_VERSION}")
  export PYTHON_BIN_PATH
  export USE_DEFAULT_PYTHON_LIB_PATH=1
  export CC_OPT_FLAGS="-march=native"
  export TF_NEED_JEMALLOC=1
  export TF_NEED_GCP=0
  export TF_NEED_HDFS=0
  export TF_ENABLE_XLA=0
  export TF_NEED_OPENCL=0
  export TF_NEED_CUDA=0
  export TF_NEED_MKL=0
  export TF_NEED_VERBS=0
  export TF_NEED_MPI=0
  export TF_NEED_S3=0
  export TF_NEED_GDR=0
  ./configure
  bazel build  -c opt \
      --copt=-maes --copt=-mavx --copt=-mmmx --copt=-mpopcnt --copt=-msse --copt=-msse2 --copt=-msse4.1 --copt=-msse4.2 --copt=-mssse3 \
      --local_resources 2048,.5,1.0 \
      //tensorflow/tools/pip_package:build_pip_package
  bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg/
}

pushd "${TENSORFLOW_REPO}"
  TENSORFLOW_VERSION_LATEST=$(git describe --tags $(git rev-list --tags -000-max-count=1))
  TENSORFLOW_VERSION="${TENSORFLOW_VERSION:-${TENSORFLOW_VERSION_LATEST}}"
  git checkout "${TENSORFLOW_VERSION}" -f
  git reset --hard HEAD
  which python3.5 && _build "3.5"
  which python3.6 && _build "3.6"
popd
