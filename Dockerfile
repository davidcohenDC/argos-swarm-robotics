# ARGoS 3 is not packaged for current Ubuntu releases, so this image builds it
# from source at a pinned commit. The same image runs the labs headless
# (scripts/run.sh), records the GIFs (scripts/record.sh) and backs the CI.
# A ready copy is published as ghcr.io/davidcohendc/argos-swarm-robotics.
FROM ubuntu:24.04

ARG ARGOS_COMMIT=4bb398cd6bfdd09fc919f24c9cccbff38370849b
# Every release ships a tarball of that commit; it is used when the clone fails.
ARG ARGOS_SOURCE_FALLBACK=https://github.com/davidcohenDC/argos-swarm-robotics/releases/latest/download/argos3-source.tar.gz

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake git ca-certificates curl \
        libfreeimage-dev libfreeimageplus-dev \
        qtbase5-dev qt5-qmake qtbase5-dev-tools \
        freeglut3-dev libxi-dev libxmu-dev \
        liblua5.3-dev lua5.3 \
        libgl1-mesa-dri xvfb ffmpeg xmlstarlet bc \
    && rm -rf /var/lib/apt/lists/*

RUN ( git clone https://github.com/ilpincy/argos3.git /tmp/argos3 \
      && git -C /tmp/argos3 checkout --quiet "$ARGOS_COMMIT" ) \
    || ( rm -rf /tmp/argos3 && mkdir -p /tmp/argos3 \
      && curl -fsSL "$ARGOS_SOURCE_FALLBACK" | tar -xz -C /tmp/argos3 --strip-components=1 ) \
    && cmake -S /tmp/argos3/src -B /tmp/argos3/build \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=/usr/local \
         -DARGOS_DOCUMENTATION=OFF \
         -DARGOS_BUILD_NATIVE=OFF \
    && cmake --build /tmp/argos3/build -j"$(nproc)" \
    && cmake --install /tmp/argos3/build \
    && ldconfig \
    && rm -rf /tmp/argos3

# Qt under Xvfb: no GPU, software OpenGL, no shared memory between processes.
ENV LIBGL_ALWAYS_SOFTWARE=1 QT_X11_NO_MITSHM=1

WORKDIR /work
