FROM ubuntu:latest

LABEL com.github.actions.name="clang-format"
LABEL com.github.actions.description="Apply clang-format to code"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="gray-dark"

LABEL repository="https://github.com/bright-tools/clang-format-action"
LABEL maintainer="bright-tools <dev@brightsilence.com>"

WORKDIR /build
RUN apt-get update
RUN apt-get -qq -y install curl clang-format jq

ADD runchecks.sh /entrypoint.sh
COPY . .
CMD ["bash", "/entrypoint.sh"]
