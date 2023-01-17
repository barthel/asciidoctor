# Build ASCIIToSVG - @see: https://github.com/asciitosvg/asciitosvg
FROM golang:1-alpine as a2s

RUN apk add git \
    && go install github.com/asciitosvg/asciitosvg/cmd/a2s@latest

# =========================================

FROM uwebarthel/docker-asciidoctor
LABEL MAINTAINERS="barthel <barthel@users.noreply.github.com>"

# This is the root/work directory within the docker image, where the Asciidoctor works in.
# It will be use to mount/bind an docker volume on it.
ARG DOCUMENT_ROOT_DIRECTORY=/documents

# This directory contains the raw Asciidoctor document sources.
ARG DOCUMENT_SRC_DIRECTORY=${DOCUMENT_ROOT_DIRECTORY}/src/doc
# The directory with a Asciidoctor theme for HTML and PDF
ARG DOCUMENT_THEME_DIRECTORY=${DOCUMENT_ROOT_DIRECTORY}/theme

# The output directory where the finished documents will be stored.
ARG OUTPUT_DIRECTORY=${DOCUMENT_ROOT_DIRECTORY}/docs

# The Asciidoctor HTML theme based on CSS.
# These parameters are used as Asciidoctor parameter.
ARG HTML_STYLESHEET=_project.css
ARG HTML_STYLESDIR=${DOCUMENT_THEME_DIRECTORY}

# The Asciidoctor PDF theme.
# This parameter is used as Asciidoctor parameter.
ARG PDF_THEME=${DOCUMENT_THEME_DIRECTORY}/_project-theme.yml

# The document version and the actual/publishing date.
ARG PROJECT_VERSION="$(git rev-parse --short HEAD)"
ARG REVISION_DATE="$(date +\"%d. %B %Y\")"

# Adds edge/testing package repo for actdiag
# RUN echo "@edge_testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
#     && apk fix

# Install blockdiag / actdiag - @see: https://github.com/blockdiag/actdiag
# RUN apk --no-cache add py3-actdiag@edge_testing \
#     # Install blockdiag - @see: https://github.com/blockdiag/actdiag
#     && apk --no-cache add py3-blockdiag@edge_testing \
#     # Install blockdiag - @see: https://github.com/nwdiag/actdiag
#     && apk --no-cache add py3-nwdiag@edge_testing \
#     # Install blockdiag - @see: https://github.com/seqdiag/actdiag
#     && apk --no-cache add py3-seqdiag@edge_testing

# Install erd - @see: https://github.com/BurntSushi/erd
# RUN wget https://github.com/BurntSushi/erd/releases/download/v0.2.1.0-RC1/erd_static-x86-64 -P /usr/local/bin/ \
#     && chmod +x /usr/local/bin/erd_static-x86-64 \
#     && ln -s -f /usr/local/bin/erd_static-x86-64 /usr/local/bin/erd

# Install imagemagick for meme - @see: https://asciidoctor.org/docs/asciidoctor-diagram/#meme
RUN apk --no-cache add imagemagick

# # Install mermaid.cli - @see: https://github.com/mermaid-js/mermaid.cli
# # @see: https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-on-alpine
# # @see: https://github.com/puppeteer/puppeteer/blob/v2.1.1/docs/api.md#environment-variables
# # @see: https://github.com/puppeteer/puppeteer/issues/5403#issuecomment-590864378
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
# ENV PUPPETEER_PRODUCT chrome
# ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
# RUN echo -e "@v3.9_community http://dl-cdn.alpinelinux.org/alpine/v3.9/community\n@v3.9_main http://dl-cdn.alpinelinux.org/alpine/v3.9/main" >> /etc/apk/repositories \
#     && apk --no-cache add   nodejs \
#                             libevent@v3.9_main~=2.1 \
#                             chromium@v3.9_community~=72 \
#     && apk --no-cache --virtual yarn-dependencies add yarn \
#     && yarn global add puppeteer @mermaid-js/mermaid-cli \
#     && yarn install \
#     && echo -e "{\n\t\"headless\": true,\n\t\"ignoreHTTPSErrors\": true,\n\t\"args\": [\n\t\t\"--no-sandbox\",\n\t\t\"--allow-insecure-localhost\"\n,\n\t\t\"--timeout 30000\"\n\t]\n}" > /tmp/puppeteer-config.json \
#     && mv /usr/local/bin/mmdc /usr/local/bin/mmdc.node \
#     && echo -e "#!/usr/bin/env bash\n/usr/local/bin/mmdc.node -p /tmp/puppeteer-config.json \${@}" > /usr/local/bin/mmdc \
#     && chmod +x /usr/local/bin/mmdc \
#     && apk del yarn-dependencies

# Install mscgen - @see: http://www.mcternan.me.uk/mscgen/
RUN apk --no-cache add tar \
    && wget -q -O- http://www.mcternan.me.uk/mscgen/software/mscgen-static-0.20.tar.gz | tar -xvz -C /tmp \
    && cp /tmp/mscgen-0.20/bin/mscgen /usr/local/bin/ \
    && chmod +x /usr/local/bin/mscgen

# Cleans up and Removes apk cache
RUN rm -rf /var/cache/apk/*

WORKDIR "${DOCUMENT_ROOT_DIRECTORY}"
COPY ./entrypoint.sh /entrypoint.sh
COPY ./execute_asciidoctor.sh /execute_asciidoctor.sh

# Install ASCIIToSVG
COPY --from=a2s /go/bin/a2s /usr/local/bin/

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

CMD [ "/bin/sh", "/execute_asciidoctor.sh" ]
