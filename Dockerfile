FROM ubuntu:22.04 as build
WORKDIR /neos

# Set variables
ARG USERNAME=""
ARG PASSWORD=""
ENV USER root
ENV HOME /root
RUN if [ "$USERNAME" = "" ]; then \
  echo "USERNAME" && exit 1; \
  fi \
  && if [ "$PASSWORD" = "" ]; then \
  echo "PASSWORD" && exit 1; \
  fi

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
  && echo steam steam/license note '' | debconf-set-selections

# Install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends ca-certificates locales steamcmd \
  && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Update SteamCMD
RUN steamcmd +quit

# Install NeosVR
RUN steamcmd \
  +force_install_dir /neos \
  +login kioriy95 Croton31Zunda \
  +app_update 740250 -beta headless-client -betapassword nSRDU739h17f9Qce6ZeZ validate +quit

FROM ubuntu:22.04
WORKDIR /neos

# Install Mono
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  gnupg ca-certificates
RUN gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb https://download.mono-project.com/repo/ubuntu vs-bionic main" | tee /etc/apt/sources.list.d/mono-official-vs.li
RUN apt-get update \
  && apt-get install -y tzdata \
  && apt-get install -y --no-install-recommends \
  mono-devel

# Copy NeosVR
COPY --from=build /neos /neos

ENTRYPOINT [ "mono" ]
CMD [ "Neos.exe" ]
