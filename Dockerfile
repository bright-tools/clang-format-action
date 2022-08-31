FROM ubuntu:22.04

LABEL com.github.actions.name="clang-format"
LABEL com.github.actions.description="Apply clang-format to code"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="gray-dark"

LABEL repository="https://github.com/bright-tools/clang-format-action"
LABEL maintainer="bright-tools <dev@brightsilence.com>"

ENV INPUT_CLANGVERSION=${INPUT_CLANGVERSION:-""}

WORKDIR /build
RUN apt-get update
RUN echo "Clang ${INPUT_CLANGVERSION}"
RUN apt-get -qq -y install curl clang-format-${INPUT_CLANGVERSION} jq
RUN ln -s /usr/bin/clang-format-$INPUT_CLANGVERSION /usr/bin/clang-format-action

ADD runchecks.sh /entrypoint.sh
COPY . .
CMD ["bash", "/entrypoint.sh"]
