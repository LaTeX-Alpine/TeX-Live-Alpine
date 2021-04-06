FROM alpine:edge

ARG FIX_ALL_GOTCHAS_SCRIPT_LOCATION
ARG ETC_ENVIRONMENT_LOCATION
ARG CLEANUP_SCRIPT_LOCATION

# Depending on the base image used, we might lack wget/curl/etc to fetch ETC_ENVIRONMENT_LOCATION.
ADD $FIX_ALL_GOTCHAS_SCRIPT_LOCATION .
ADD $CLEANUP_SCRIPT_LOCATION .

# We need git to pip install directly from a git repository.
# We need openssh-client to git clone via SSH
# (it's more secure to use a deploy key than a password).
RUN set -o allexport \
    && . ./fix_all_gotchas.sh \
    && set +o allexport \
    && apk add --no-cache texlive \
    && tlmgr update --self \
    # install ms does not solve "everyshi.sty not found", trying deprecated old everyshi
    && tlmgr install mdframed needspace zref tcolorbox listings environ translator beamer ms everyshi \
    # Annoyingly, the build will not fail if tlmgr fails.
    && . ./cleanup.sh

