FROM node:22-bookworm-slim

ARG PI_PACKAGE=@mariozechner/pi-coding-agent

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash ca-certificates curl git jq openssh-client python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g "${PI_PACKAGE}"

RUN python3 -m venv /opt/ha-tools \
    && /opt/ha-tools/bin/pip install --no-cache-dir yamllint

ENV PATH="/opt/ha-tools/bin:${PATH}" \
    HOME=/home/agent

RUN useradd --create-home --uid 10001 --shell /bin/bash agent \
    && mkdir -p /workspace /home/agent/.pi \
    && chown -R agent:agent /workspace /home/agent

COPY --chown=agent:agent scripts/ /opt/pi-ha/scripts/
RUN chmod +x /opt/pi-ha/scripts/*.sh

USER agent
WORKDIR /workspace

ENTRYPOINT ["/opt/pi-ha/scripts/entrypoint.sh"]
CMD ["pi"]
