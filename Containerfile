# https://github.com/awesome-containers/static-bash
ARG STATIC_BASH_VERSION=5.2.15
ARG STATIC_BASH_IMAGE=ghcr.io/awesome-containers/static-bash

# https://github.com/awesome-containers/alpine-build-essential
ARG BUILD_ESSENTIAL_VERSION=3.17
ARG BUILD_ESSENTIAL_IMAGE=ghcr.io/awesome-containers/alpine-build-essential


FROM $STATIC_BASH_IMAGE:$STATIC_BASH_VERSION AS static-bash
FROM $BUILD_ESSENTIAL_IMAGE:$BUILD_ESSENTIAL_VERSION AS build

# hadolint ignore=DL3018
RUN apk add --no-cache pcre2-dev

# https://gnupg.org/download/index.html
ARG GNUPG_VERSION=2.4.1
ARG LIBGPG_ERROR_VERSION=1.47
ARG LIBGCRYPT_VERSION=1.10.2
ARG LIBASSUAN_VERSION=2.5.5
ARG LIBKSBA_VERSION=1.6.3
ARG NPTH_VERSION=1.6
ARG PINENTRY_VERSION=1.2.1

ARG GNUPG_FTP=https://gnupg.org/ftp/gcrypt

WORKDIR /src
COPY download.sh download.sh
RUN ./download.sh gnupg libgpg-error libgcrypt libassuan libksba npth pinentry

WORKDIR /gnupg-libs
ARG LIBS_DIR=/gnupg-libs
ARG CFLAGS='-w -g -Os -static'

WORKDIR /src/libgpg-error
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" --enable-shared=no --enable-static=yes \
        --disable-nls --disable-doc --disable-languages; \
    make -j"$(nproc)"; \
    make install

# hotfix before 2.5.6 libassuan released
WORKDIR /gnupg-libs/bin/
RUN ln -s gpgrt-config gpg-error-config

WORKDIR /src/libgcrypt
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" --enable-shared=no --enable-static=yes \
        --disable-nls --disable-doc --with-libgpg-error-prefix="$LIBS_DIR"; \
    make -j"$(nproc)"; \
    make install

WORKDIR /src/libassuan
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" --enable-shared=no --enable-static=yes \
        --disable-nls --disable-doc --with-libgpg-error-prefix="$LIBS_DIR"; \
    make -j"$(nproc)"; \
    make install

WORKDIR /src/libksba
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" --enable-shared=no --enable-static=yes \
        --disable-nls --disable-doc --with-libgpg-error-prefix="$LIBS_DIR"; \
    make -j"$(nproc)"; \
    make install

WORKDIR /src/npth
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" --enable-shared=no --enable-static=yes \
        --disable-nls --disable-doc; \
    make -j"$(nproc)"; \
    make install

WORKDIR /src/pinentry
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" --enable-pinentry-tty \
        --with-libgpg-error-prefix="$LIBS_DIR" \
        --with-libassuan-prefix="$LIBS_DIR" \
        --disable-nls --disable-doc --disable-ncurses \
        --disable-pinentry-curses \
        --disable-pinentry-emacs \
        --disable-pinentry-gtk2 \
        --disable-pinentry-gnome3 \
        --disable-pinentry-qt \
        --disable-pinentry-tqt \
        --disable-pinentry-fltk; \
    make -j"$(nproc)"; \
    make install

ARG PREFIX=''
WORKDIR /src/gnupg
RUN set -xeu; \
    ./configure --prefix="$LIBS_DIR" \
        --with-libgpg-error-prefix="$LIBS_DIR" \
        --with-libgcrypt-prefix="$LIBS_DIR" \
        --with-libassuan-prefix="$LIBS_DIR" \
        --with-ksba-prefix="$LIBS_DIR" \
        --with-npth-prefix="$LIBS_DIR" \
        --with-agent-pgm="$PREFIX/bin/gpg-agent" \
        --with-pinentry-pgm="$PREFIX/bin/pinentry" \
        --disable-nls --disable-doc --disable-ldap --disable-sqlite \
        --disable-ccid-driver --disable-card-support --disable-photo-viewers; \
    make -j"$(nproc)"; \
    make install

WORKDIR /gnupg-libs/bin
# hadolint ignore=DL4006
RUN set -eu; \
    for bin in ./*; do \
        file "$bin" -b --mime-type | grep -qw 'application/x-executable' || \
            continue; \
        ! ldd "$bin" && :; \
        strip -s -R .comment --strip-unneeded "$bin"; \
    done

# static gnupg image
FROM static-bash
COPY --from=build /gnupg-libs/bin /bin/
