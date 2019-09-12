#!/usr/bin/env bash

OS_NAME="$(uname | awk '{print tolower($0)}')"

SHELL_DIR=$(dirname $0)

PROFILE=$1

pushd ${SHELL_DIR}

git pull

mkdir -p build
mkdir -p config

if [ -f config/deepracer-model.sh ]; then
    source config/deepracer-model.sh
fi

_load() {
    SELECTED=

    URL=$1

    if [ "${URL}" == "" ]; then
        return
    fi

    TMP=build/temp.txt

    curl -sL ${URL} > ${TMP}

    COUNT=$(cat ${TMP} | wc -l | xargs)

    if [ "${COUNT}" -gt 1 ]; then
        if [ "${OS_NAME}" == "darwin" ]; then
            RND=$(ruby -e "p rand(1...${COUNT})")
        else
            RND=$(shuf -i 1-${COUNT} -n 1)
        fi
    else
        RND=1
    fi

    echo "${RND} / ${COUNT}"

    if [ ! -z ${RND} ]; then
        SELECTED=$(sed -n ${RND}p ${TMP})
    fi
}

# PROFILE
if [ "${PROFILE}" == "" ]; then
    echo "load ${PROFILE_URL}"
    _load "${PROFILE_URL}"

    export PROFILE="${SELECTED:-$PROFILE}"
fi

echo "PROFILE: ${PROFILE}"

if [ -f config/${PROFILE}.sh ]; then
    echo "load config/${PROFILE}.sh"
    source config/${PROFILE}.sh
fi

# MODEL
_load "${MODEL_URL}"

echo "MODEL: ${SELECTED}"

if [ "${SELECTED}" != "" ]; then
    export MODEL="${SELECTED}"
fi

# submit
python3 submit.py

popd
