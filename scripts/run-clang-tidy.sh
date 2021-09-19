#!/usr/bin/env bash
#
#  Copyright 2017 Toyota Research Institute
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

LAST_ARG=${@:$#}
EXEC_ROOT=$(bazel info execution_root)
BAZEL_EXTERNAL=${EXEC_ROOT}/external
BAZEL_THIRD_PARTY=${EXEC_ROOT}/third_party
IBEX_VERSION=2.7.4

clang-tidy "$@" -header-filter="$(realpath .)" -system-headers=0 -p ./ \
           -- \
           -std=c++17 \
           -I./ \
           -x c++ \
           -I bazel-genfiles \
	   -I"/opt/libibex/${IBEX_VERSION}/include" \
	   -I"/opt/libibex/${IBEX_VERSION}/include/ibex" \
	   -I"/opt/libibex/${IBEX_VERSION}/include/ibex/3rd" \
	   -I"/usr/local/opt/ibex@${IBEX_VERSION}/include" \
	   -I"/usr/local/opt/ibex@${IBEX_VERSION}/include/ibex" \
	   -I"/usr/local/opt/ibex@${IBEX_VERSION}/include/ibex/3rd" \
	   -I/usr/local/opt/clp/include/clp/coin \
	   -I/usr/local/opt/coinutils/include/coinutils/coin \
	   -I/usr/local/opt/python@2/Frameworks/Python.framework/Versions/2.7/include/python2.7 \
           -isystem "${BAZEL_EXTERNAL}/cds" \
           -isystem "${BAZEL_EXTERNAL}/com_google_googletest/googletest/include" \
           -isystem "${BAZEL_EXTERNAL}/drake_symbolic" \
           -isystem "${BAZEL_EXTERNAL}/ezoptionparser" \
           -isystem "${BAZEL_EXTERNAL}/fmt/include" \
           -isystem "${BAZEL_EXTERNAL}/picosat" \
           -isystem "${BAZEL_EXTERNAL}/pybind11/include" \
           -isystem "${BAZEL_EXTERNAL}/spdlog/include" \
           -isystem "${BAZEL_THIRD_PARTY}/com_github_robotlocomotion_drake" \
           -isystem "${BAZEL_THIRD_PARTY}/com_github_progschj_threadpool" \
           -isystem "${BAZEL_THIRD_PARTY}/com_github_pinam45_dynamic_bitset" \
           -isystem /usr/local/include \
           -isystem /usr/local/opt/flex/include \
           -isystem /usr/local/opt/llvm/include/c++/v1 \

if [ "${LAST_ARG}" == "--fix" ];
then
    git-clang-format -f
fi
