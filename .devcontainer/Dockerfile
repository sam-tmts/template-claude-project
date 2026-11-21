# Dev container for projects built from template-claude-project (ADR-0004).
#
# Adapted from Anthropic's reference dev container:
#   https://github.com/anthropics/claude-code/tree/26a5b52bb5d9f53bff6b4804214ec88deab78ce3/.devcontainer
#
# Differences from upstream:
#   - Base image node:22 instead of node:20 (Node 20 is out of support).
#   - Removed git-delta and the zsh/powerline theme: both were downloaded at build time
#     without checksum verification, and neither is needed.
#   - Removed editor convenience packages (fzf, zsh, man-db, vim, gnupg2, unzip).
#   - Added gitleaks, copied from its official image so Dependabot can update it.
#   - Claude Code pinned to an exact version (set in devcontainer.json) instead of
#     "latest"; auto-update is switched off at runtime.
#   - The firewall allowlist is copied into the image, owned by root, so nothing running
#     in the container can widen it. Changing it means editing
#     .devcontainer/allowed-domains.txt (a protected path, so a CR) and rebuilding.
#   - The node user may run the firewall script through sudo with no arguments, and
#     nothing else.
#   - Firewall script changes are listed in init-firewall.sh.
#
# Image references use tags until the first build on the owner's Mac records their
# digests (CR-0001 verification); they are then pinned as tag@sha256:digest.

# gitleaks, for the git pre-commit hook. Its official image holds a static binary.
FROM ghcr.io/gitleaks/gitleaks:v8.30.1 AS gitleaks

FROM node:22-bookworm

ARG TZ=UTC
ENV TZ="$TZ"

# Tools for development and for the firewall (iptables, ipset, dnsutils, aggregate,
# jq, curl). Versions follow the Debian release of the base image.
RUN apt-get update && apt-get install -y --no-install-recommends \
    aggregate \
    ca-certificates \
    curl \
    dnsutils \
    gh \
    git \
    iproute2 \
    ipset \
    iptables \
    jq \
    less \
    nano \
    procps \
    sudo \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=gitleaks /usr/bin/gitleaks /usr/local/bin/gitleaks
RUN gitleaks version

ENV DEVCONTAINER=true

# npm global installs go somewhere the non-root user owns
RUN mkdir -p /usr/local/share/npm-global /workspace /home/node/.claude \
  && chown -R node:node /usr/local/share/npm-global /workspace /home/node/.claude

WORKDIR /workspace

USER node
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV EDITOR=nano
ENV VISUAL=nano

ARG CLAUDE_CODE_VERSION
RUN test -n "$CLAUDE_CODE_VERSION" \
  && npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

# Firewall: script and allowlist are root-owned and read-only for the node user.
USER root
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY allowed-domains.txt /usr/local/etc/allowed-domains.txt
RUN chmod 0755 /usr/local/bin/init-firewall.sh \
  && chmod 0644 /usr/local/etc/allowed-domains.txt \
  && echo 'node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh ""' > /etc/sudoers.d/node-firewall \
  && chmod 0440 /etc/sudoers.d/node-firewall
USER node
