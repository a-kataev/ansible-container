ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-alpine

RUN set -x && \
  apk add --no-cache \
    su-exec openssh-client curl \
    jq tree git && \
  mkdir /entrypoint.d && \
  adduser -h /ansible -s /bin/sh -D -u 1000 ansible && \
  mkdir -p /ansible/.ansible && \
  chown -R ansible:ansible /ansible && \
  mkdir -p /root/.ansible

WORKDIR /ansible

ARG ANSIBLE_CORE_VERSION=2.16.4
ARG ANSIBLE_LINT_VERSION=24.2.1
ARG YAMLLINT_VERSION=1.35.1
ARG MITOGEN_VERSION=0.3.4

ENV ANSIBLE_CORE_VERSION=${ANSIBLE_CORE_VERSION} \
  ANSIBLE_LINT_VERSION=${ANSIBLE_LINT_VERSION} \
  YAMLLINT_VERSION=${YAMLLINT_VERSION} \
  MITOGEN_VERSION=${MITOGEN_VERSION}

RUN set -x && \
  apk add --no-cache --virtual .build-deps \
    gcc libc-dev libffi-dev && \
  export PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore && \
  pip install ansible-core==${ANSIBLE_CORE_VERSION} && \
  pip install ansible-lint==${ANSIBLE_LINT_VERSION} && \
  pip install yamllint==${YAMLLINT_VERSION} && \
  pip install mitogen==${MITOGEN_VERSION} && \
  apk del --no-cache .build-deps && \
  find /usr/local -not -path '*/ansible/*' -depth \( \
    \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \
    \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
  \) -exec rm -rf '{}' + && \
  rm -rf /root/.cache /tmp/*

RUN set -x && \
  pip freeze

COPY scripts/entrypoint.sh /

RUN set -x && \
  chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["sh"]
