#!/bin/sh

SSH_AGENT_DISABLED=${SSH_AGENT_DISABLED}
ENTRYPOINT_SCRIPTS_DISABLED=${ENTRYPOINT_SCRIPTS_DISABLED}
SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-~/.ssh-agent.sock}

trap stop EXIT

stop() {
  local code="${?}"
  if [[ -z "${SSH_AGENT_DISABLED}" ]]; then
    echo "Stop ssh-agent"
    /usr/bin/ssh-agent -s -k >/dev/null 2>&1
    if [[ -S "${SSH_AUTH_SOCK}" ]]; then rm -rf "${SSH_AUTH_SOCK}"; fi
  fi
  echo "Exit code ${code}"
  exit "${code}"
}

if [[ -z "${SSH_AGENT_DISABLED}" ]]; then
  if [[ -S "${SSH_AUTH_SOCK}" ]]; then rm -rf "${SSH_AUTH_SOCK}"; fi
  echo "Start ssh-agent"
  eval $(/usr/bin/ssh-agent -s -a "${SSH_AUTH_SOCK}" 2>&1) >/dev/null 2>&1
fi

if [[ -z "${ENTRYPOINT_SCRIPTS_DISABLED}" ]]; then
  find /entrypoint.d/ -mindepth 1 -maxdepth 1 -type f -name '*.sh' -executable -print 2>/dev/null | \
    sort -n | while read -r script; do
    echo "Launching ${script}"
    ${script}
  done
fi

if [[ -z "${SSH_AGENT_DISABLED}" ]]; then
  if [[ -n "${SSH_AGENT_PID}" ]] && [[ -S "${SSH_AUTH_SOCK}" ]]; then "${@}"; fi
else
  "${@}"
fi
