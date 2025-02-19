FROM alpine:edge

ARG FIX_ALL_GOTCHAS_SCRIPT_LOCATION
ARG ETC_ENVIRONMENT_LOCATION
ARG CLEANUP_SCRIPT_LOCATION

# Depending on the base image used, we might lack wget/curl/etc to fetch ETC_ENVIRONMENT_LOCATION.
ADD $FIX_ALL_GOTCHAS_SCRIPT_LOCATION .
ADD $CLEANUP_SCRIPT_LOCATION .

RUN apk --no-cache add \
      xz \
      wget \
      perl \
      tar \
      fontconfig-dev && \
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    mkdir /tmp/install-tl && \
    tar -xzf install-tl-unx.tar.gz -C /tmp/install-tl --strip-components=1 && \
    /tmp/install-tl/install-tl

# We need git to pip install directly from a git repository.
# We need openssh-client to git clone via SSH
# (it's more secure to use a deploy key than a password).
RUN set -o allexport \
    && . ./fix_all_gotchas.sh \
    && set +o allexport \
    # && apk add --no-cache texlive \ # does not install tlmgr
    && wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && ls install-tl-unx.tar.gz \
    && tar --help \
    && tar x -z -f install-tl-unx.tar.gz \
    && ls install-tl-* \
    && cd install-tl-* \
    && apk add --no-cache perl \
    && perl install-tl --help \
    # Loading http://www.ctan.org/tex-archive/systems/texlive/tlnet/tlpkg/texlive.tlpdb
    # cannot contact mirror.ctan.org, returning a backbone server!
    # install-tl: TLPDB::from_file could not initialize from: http://www.ctan.org/tex-archive/systems/texlive/tlnet/tlpkg/texlive.tlpdb
    # install-tl: Maybe the repository setting should be changed.
    # && perl install-tl -select-repository http://mirrors.ibiblio.org/CTAN/systems/texlive/tlnet/ \
    # install-tl: Extra arguments `http://mirrors.ibiblio.org/CTAN/systems/texlive/tlnet/' what? please tell me it's not interactive
    && perl install-tl -select-repository \
    && tlmgr update --self \
    # install ms does not solve "everyshi.sty not found", trying deprecated old everyshi
    && tlmgr install mdframed needspace zref tcolorbox listings environ translator beamer ms everyshi \
    # Annoyingly, the build will not fail if tlmgr fails.
    && . ./cleanup.sh

