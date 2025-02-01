# Use a specific version tag instead of latest for better reproducibility
FROM azul/zulu-openjdk:8u432-jre

# Build arguments
ARG REW_VERSION="5_40_beta_68"
ARG INSTALL_DIR="/opt/rew"
ARG TEMP_DIR="/tmp"

# Metadata labels
LABEL org.opencontainers.image.authors="docker-maint@sangoku.work, John Mulcahy"
LABEL org.opencontainers.image.title="Room EQ Wizard"
LABEL org.opencontainers.image.version="${REW_VERSION}"
LABEL org.opencontainers.image.description="REW audio analysis in headless mode"
LABEL org.opencontainers.image.licenses="Proprietary"

# Environment variables grouped by purpose

ENV DISPLAY=:99 \
    INSTALLER_FILE="REW_linux_no_jre_${REW_VERSION}-api.sh"

# Create non-root user first for better layer caching
RUN set -ex \
    && groupadd -r rew \
    && useradd -r -G audio -g rew --create-home  -s /sbin/nologin -c "REW user" rew \
    && mkdir -p ${INSTALL_DIR} /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Create working directory
WORKDIR ${INSTALL_DIR}

COPY --chown=rew:rew \
    entrypoint.sh preferences.txt logging.properties ${INSTALL_DIR}/

# Install dependencies and REW
RUN set -ex && \
    # Update and install dependencies
    apt-get -yq update && \
    apt-get -yqq install --no-install-recommends \
    curl \
    ca-certificates \
    xvfb \
    libasound2 && \
    # Download and install REW
    curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --retry-delay 2 \
    --output "${TEMP_DIR}/installer.sh" \
    "https://roomeqwizard.com/installers/${INSTALLER_FILE}" && \
    # Make installer executable and run
    chmod +x "${TEMP_DIR}/installer.sh" entrypoint.sh && \
    "${TEMP_DIR}/installer.sh" -q -dir "${INSTALL_DIR}" && \
    echo "-Djava.util.logging.config.file=${INSTALL_DIR}/logging.properties" >> roomeqwizard.vmoptions && \
    echo "-Drew.preferences.file=${INSTALL_DIR}/preferences.txt" >> roomeqwizard.vmoptions && \
    # Cleanup
    apt-get clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/apt/archives/* \
    "${TEMP_DIR}/installer.sh" && \
    # Set permissions
    chown -R rew:rew ${INSTALL_DIR}

# Switch to non-root user
USER rew

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD xdpyinfo -display :99 >/dev/null && pgrep -f roomeqwizard >/dev/null

# Expose port
EXPOSE 4735

# Set entrypoint
ENTRYPOINT ["/opt/rew/entrypoint.sh"]
