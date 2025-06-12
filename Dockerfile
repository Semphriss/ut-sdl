ARG UT_VERSION=20.04
ARG ARCH=amd64
ARG BUILD_TYPE=Release

FROM clickable/ci-$UT_VERSION-$ARCH AS base

# Required for args to be available in the build stage
ARG UT_VERSION
ARG ARCH
ARG BUILD_TYPE

# For the latest revision, use "main" for SDL3 & SDL2-compat and "SDL2" for SDL2
ARG SDL3REF=ubuntu-touch
ARG SDL2COMPATREF=main
ARG SDL3IMGREF=main # Awaiting fixes, coming after 3.2.4
ARG SDL2IMGREF=SDL2 # Awaiting fixes, coming after 2.8.8
ARG SDL3TTFREF=release-3.2.2
ARG SDL2TTFREF=release-2.24.0
#ARG SDL3MIXREF=main # Not yet stable
ARG SDL2MIXREF=release-2.8.1
#ARG SDL3NETREF=main # Not yet stable
ARG SDL2NETREF=release-2.2.0

ARG CMAKE_ARGS=-DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=$BUILD_TYPE

ENV DEBIAN_FRONTEND=noninteractive

# Everything in one line, else Docker will "export layers" and take >16gb, which
# isn't appreciated by GitHub Actions
RUN apt-get update && apt-get install -y build-essential cmake git nasm \
 && apt-get install -y libasound2-dev:$ARCH libaudio-dev:$ARCH libjack-dev:$ARCH libsndio-dev:$ARCH libx11-dev:$ARCH libxext-dev:$ARCH libxrandr-dev:$ARCH libxcursor-dev:$ARCH libxfixes-dev:$ARCH libxi-dev:$ARCH libxss-dev:$ARCH libxkbcommon-dev:$ARCH libdrm-dev:$ARCH libgbm-dev:$ARCH libgl1-mesa-dev:$ARCH libgles2-mesa-dev:$ARCH libegl1-mesa-dev:$ARCH libdbus-1-dev:$ARCH libudev-dev:$ARCH libwayland-dev:$ARCH libfreetype-dev:$ARCH \
 && git clone --depth=1 https://github.com/Semphriss/SDL.git -b $SDL3REF SDL3 \
 && cd /SDL3 \
 && git submodule update --init --recursive \
 && cmake -B build -S . $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL3 \
 && git clone --depth=1 https://github.com/libsdl-org/sdl2-compat.git -b $SDL2COMPATREF SDL2 \
 && cd /SDL2 \
 && git submodule update --init --recursive \
 && cmake -B build -S . $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL2 \
 && git clone --depth=1 https://github.com/libsdl-org/SDL_image.git -b $SDL3IMGREF SDL3_image \
 && cd /SDL3_image \
 && git submodule update --init --recursive \
 && cmake -B build -S . -DSDLIMAGE_VENDORED=ON -DAOM_NEON_INTRIN_FLAG=-mfpu=neon -DDAV1D_ASM=OFF $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL3_image \
 && git clone --depth=1 https://github.com/libsdl-org/SDL_image.git -b $SDL2IMGREF SDL2_image \
 && cd /SDL2_image \
 && git submodule update --init --recursive \
 && cmake -B build -S . -DSDL2IMAGE_VENDORED=ON -DDAV1D_ASM=OFF $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL2_image \
 && git clone --depth=1 https://github.com/libsdl-org/SDL_ttf.git -b $SDL3TTFREF SDL3_ttf \
 && cd /SDL3_ttf \
 && git submodule update --init --recursive \
 && cmake -B build -S . -DSDLTTF_VENDORED=ON $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL3_ttf \
 && git clone --depth=1 https://github.com/libsdl-org/SDL_ttf.git -b $SDL2TTFREF SDL2_ttf \
 && cd /SDL2_ttf \
 && git submodule update --init --recursive \
 && cmake -B build -S . -DSDL2TTF_VENDORED=ON $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL2_ttf \
 && git clone --depth=1 https://github.com/libsdl-org/SDL_mixer.git -b $SDL2MIXREF SDL2_mixer \
 && cd /SDL2_mixer \
 && git submodule update --init --recursive \
 && cmake -B build -S . -DSDL2MIXER_VENDORED=ON -DWAVPACK_ENABLE_ASM=no $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL2_mixer \
 && git clone --depth=1 https://github.com/libsdl-org/SDL_net.git -b $SDL2NETREF SDL2_net \
 && cd /SDL2_net \
 && git submodule update --init --recursive \
 && cmake -B build -S . $CMAKE_ARGS \
 && cmake --build build --parallel \
 && cmake --install build \
 && cd / \
 && rm -rf /SDL2_net \
 && tar -czf /utsdl.tgz /usr/local/include/SDL* /usr/local/lib/cmake/SDL* \
       /usr/local/lib/pkgconfig/SDL* /usr/local/lib/pkgconfig/sdl* \
       /usr/local/lib/libSDL* /usr/local/bin/sdl*

# && git clone --depth=1 https://github.com/libsdl-org/SDL_mixer.git -b $SDL3MIXREF SDL3_mixer \
# && cd /SDL3_mixer \
# && git submodule update --init --recursive \
# && cmake -B build -S . -DSDLMIXER_VENDORED=ON -DWAVPACK_ENABLE_ASM=no $CMAKE_ARGS \
# && cmake --build build --parallel \
# && cmake --install build \
# && cd / \
# && rm -rf /SDL3_mixer \

# && git clone --depth=1 https://github.com/libsdl-org/SDL_net.git -b $SDL3NETREF SDL3_net \
# && cd /SDL3_net \
# && git submodule update --init --recursive \
# && cmake -B build -S . $CMAKE_ARGS \
# && cmake --build build --parallel \
# && cmake --install build \
# && cd / \
# && rm -rf /SDL3_net \

CMD cat /utsdl.tgz
