#!/bin/bash

set -e

# Variables
RUNNER_NAME=${1}
REGISTER_TOKEN=${2}
RUNNER_TAGS=${3}
CI_SERVER_URL=${4:-"https://gitlab.com/ci"}
CONFIG_PATH=$HOME/.gitlab-runner/config.toml

if [[ -z "$2" ]]
then
    echo "Usage: register_runner.sh RUNNER_NAME REGISTER_TOKEN RUNNER_TAGS CI_SERVER_URL"
    echo "If CI_SERVER_URL is left empty, https://gitlab.com/ci is assumed"
    exit 1
fi

if [[ -f "${CONFIG_PATH}" ]]
then
    RE="\\[\\[runners\\]\\]"
    RE="${RE}[^\\[]*"
    RE="${RE}name = \\\"${RUNNER_NAME}\\\""
    RE="${RE}[^\\[]*"
    RE="${RE}url = \\\"${CI_SERVER_URL}\\\""
    RE="${RE}[^\\[]*"
    RE="${RE}token = \\\"([^\\\"]*)\\\""
    RE="${RE}[^\\[]*"

    if [[ $(cat "${CONFIG_PATH}") =~ ${RE} ]]
    then
        echo "The runner \"${RUNNER_NAME}\" already exists."
        exit 1
    fi
fi

#    --docker-host tcp://host.docker:2375 \
#    --docker-image alpine:3.8 \
#    --docker-privileged \
#    --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
#    --docker-volumes /cache:/cache \
#    --docker-volumes /builds:/builds \

mkdir -p $HOME/gilab_runner/cache
mkdir -p $HOME/gitlab_runner/builds

gitlab-runner register \
    --non-interactive \
    --url "${CI_SERVER_URL}" \
    --name "${RUNNER_NAME}" \
    --registration-token "${REGISTER_TOKEN}" \
    --cache-dir $HOME/gitlab_runner/cache \
    --builds-dir $HOME/gitlab_runner/builds \
    --executor shell \
    --tag-list "${RUNNER_TAGS}" \
    --run-untagged="false"
