ARG UT_VERSION=20.04
ARG ARCH=amd64
ARG CLICKABLE_VERSION=8.2.0
ARG BUILD_TYPE=Release

FROM clickable/ci-$UT_VERSION-$ARCH:$CLICKABLE_VERSION AS base

FROM base AS build-amd64
ARG CMAKE_ARCH=x86_64
ARG GCC_ARCH=x86_64-linux-gnu

FROM base AS build-arm64
ARG CMAKE_ARCH=aarch64
ARG GCC_ARCH=aarch64-linux-gnu

FROM base AS build-armhf
ARG CMAKE_ARCH=
ARG GCC_ARCH=arm-linux-gnueabihf

FROM build-$ARCH

# For the latest revision, use "main" for SDL3 & SDL2-compat and "SDL2" for SDL2
ARG SDL3REF=ubuntu-touch
ARG SDL2COMPATREF=main
ARG SDL3IMGREF=release-3.2.4
ARG SDL2IMGREF=release-2.8.8
ARG SDL3TTFREF=release-3.2.2
ARG SDL2TTFREF=release-2.24.0
ARG SDL3MIXREF=main # Not yet released
ARG SDL2MIXREF=release-2.8.1
ARG SDL3NETREF=main # Not yet released
ARG SDL2NETREF=release-2.2.0

ARG CMAKE_ARGS=-DCMAKE_INSTALL_PREFIX=/usr/local \
               -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
               -DCMAKE_SYSTEM_PROCESSOR=$CMAKE_ARCH \
               -DCMAKE_C_COMPILER=$GCC_ARCH-gcc

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y build-essential cmake git nasm

RUN apt-get install -y libasound2-dev:$ARCH libpulse-dev:$ARCH libaudio-dev:$ARCH libjack-dev:$ARCH libsndio-dev:$ARCH libx11-dev:$ARCH libxext-dev:$ARCH libxrandr-dev:$ARCH libxcursor-dev:$ARCH libxfixes-dev:$ARCH libxi-dev:$ARCH libxss-dev:$ARCH libxkbcommon-dev:$ARCH libdrm-dev:$ARCH libgbm-dev:$ARCH libgl1-mesa-dev:$ARCH libgles2-mesa-dev:$ARCH libegl1-mesa-dev:$ARCH libdbus-1-dev:$ARCH libibus-1.0-dev:$ARCH libudev-dev:$ARCH fcitx-libs-dev:$ARCH libwayland-dev:$ARCH libfreetype-dev:$ARCH

# TODO: Replace SDL3 version and git URL to the latest revision (likely 3.4.0)
# when https://github.com/libsdl-org/SDL/pull/12543 will be merged. 
RUN git clone --depth=1 https://github.com/Semphriss/SDL.git -b $SDL3REF SDL3
WORKDIR /SDL3
RUN git submodule update --init --recursive
RUN cmake -B build -S . $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL3

RUN git clone --depth=1 https://github.com/libsdl-org/sdl2-compat.git -b $SDL2COMPATREF SDL2
WORKDIR /SDL2
RUN git submodule update --init --recursive
RUN cmake -B build -S . $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL2

RUN git clone --depth=1 https://github.com/libsdl-org/SDL_image.git -b $SDL3IMGREF SDL3_image
WORKDIR /SDL3_image
RUN git submodule update --init --recursive
RUN cmake -B build -S . -DSDLIMAGE_VENDORED=ON $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL3_image

RUN git clone --depth=1 https://github.com/libsdl-org/SDL_image.git -b $SDL2IMGREF SDL2_image
WORKDIR /SDL2_image
RUN git submodule update --init --recursive
RUN cmake -B build -S . -DSDL2IMAGE_VENDORED=ON $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL2_image

RUN git clone --depth=1 https://github.com/libsdl-org/SDL_ttf.git -b $SDL3TTFREF SDL3_ttf
WORKDIR /SDL3_ttf
RUN git submodule update --init --recursive
RUN cmake -B build -S . -DSDLTTF_VENDORED=ON $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL3_ttf

RUN git clone --depth=1 https://github.com/libsdl-org/SDL_ttf.git -b $SDL2TTFREF SDL2_ttf
WORKDIR /SDL2_ttf
RUN git submodule update --init --recursive
RUN cmake -B build -S . -DSDL2TTF_VENDORED=ON $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL2_ttf

#RUN git clone --depth=1 https://github.com/libsdl-org/SDL_mixer.git -b $SDL3MIXREF SDL3_mixer
#WORKDIR /SDL3_mixer
#RUN git submodule update --init --recursive
#RUN cmake -B build -S . -DSDLMIXER_VENDORED=ON $CMAKE_ARGS
#RUN cmake --build build --parallel
#RUN cmake --install build
#WORKDIR /
#RUN rm -rf /SDL3_mixer

RUN git clone --depth=1 https://github.com/libsdl-org/SDL_mixer.git -b $SDL2MIXREF SDL2_mixer
WORKDIR /SDL2_mixer
RUN git submodule update --init --recursive
RUN cmake -B build -S . -DSDL2MIXER_VENDORED=ON $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL2_mixer

#RUN git clone --depth=1 https://github.com/libsdl-org/SDL_net.git -b $SDL3NETREF SDL3_net
#WORKDIR /SDL3_net
#RUN git submodule update --init --recursive
#RUN cmake -B build -S . $CMAKE_ARGS
#RUN cmake --build build --parallel
#RUN cmake --install build
#WORKDIR /
#RUN rm -rf /SDL3_net

RUN git clone --depth=1 https://github.com/libsdl-org/SDL_net.git -b $SDL2NETREF SDL2_net
WORKDIR /SDL2_net
RUN git submodule update --init --recursive
RUN cmake -B build -S . $CMAKE_ARGS
RUN cmake --build build --parallel
RUN cmake --install build
WORKDIR /
RUN rm -rf /SDL2_net

# SDL also installs third-party libraries by default
RUN tar -czf /utsdl.tgz /usr/local/include/SDL* /usr/local/lib/cmake/SDL* \
    /usr/local/lib/pkgconfig/SDL* /usr/local/lib/pkgconfig/sdl* \
    /usr/local/lib/libSDL* /usr/local/bin/sdl*

CMD cat /utsdl.tgz
