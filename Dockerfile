FROM eclipse-temurin:17-jre-jammy

RUN useradd --system --create-home --uid 10001 languagetool \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/languagetool

COPY --chown=languagetool:languagetool LanguageToolServer/ /opt/languagetool/
COPY --chown=languagetool:languagetool docker/start-languagetool.sh /usr/local/bin/start-languagetool.sh

RUN chmod +x /usr/local/bin/start-languagetool.sh

ENV LT_PORT=8081 \
    LT_JAVA_XMS=256m \
    LT_JAVA_XMX=512m \
    LT_PUBLIC=true \
    LT_ALLOW_ORIGIN=* \
    LT_EXTRA_ARGS=

EXPOSE 8081

USER languagetool

HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=5 \
    CMD curl -fsS "http://127.0.0.1:${LT_PORT}/v2/languages" > /dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/start-languagetool.sh"]
