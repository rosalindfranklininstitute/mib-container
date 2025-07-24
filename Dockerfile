ARG UBUNTU_VERSION=24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/London

FROM ubuntu:${UBUNTU_VERSION}

# Base Install to download and process applications.
ARG CURL_VERSION="8.5.0-2ubuntu10.6" # https://packages.ubuntu.com/noble/curl
ARG UNZIP_VERSION="6.0-28ubuntu4.1" # https://packages.ubuntu.com/noble/unzip

# Matlab Runtime  Requirements from https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-runtime-deps/r2024a/ubuntu22.04
ARG CA_CERTIFICATES_VERSION="20240203" # https://packages.ubuntu.com/noble/ca-certificates
ARG GSTREAMER1_0_PLUGINS_BASE_VERSION="1.24.2-1ubuntu0.2" # https://packages.ubuntu.com/noble/gstreamer1.0-plugins-base
ARG GSTREAMER1_0_PLUGINS_GOOD_VERSION="1.24.2-1ubuntu1.1" # https://packages.ubuntu.com/noble/gstreamer1.0-plugins-good
ARG GSTREAMER1_0_TOOLS_VERSION="1.24.2-1ubuntu0.1" # https://packages.ubuntu.com/noble/gstreamer1.0-tools
ARG LIBASOUND2T64_VERSION="1.2.11-1ubuntu0.1" # https://packages.ubuntu.com/noble-updates/libasound2t64
ARG LIBATOMIC1_VERSION="14.2.0-4ubuntu2~24.04" # https://packages.ubuntu.com/noble/libatomic1
ARG LIBC6_VERSION="2.39-0ubuntu8.5" # https://packages.ubuntu.com/noble/libc6
ARG LIBCAIRO_GOBJECT2_VERSION="1.18.0-3build1" # https://packages.ubuntu.com/noble/libcairo-gobject2
ARG LIBCAIRO2_VERSION="1.18.0-3build1" # https://packages.ubuntu.com/noble/libcairo2
ARG LIBCAP2_VERSION="1:2.66-5ubuntu2.2" # https://packages.ubuntu.com/noble/libcap2
ARG LIBCUPS2T64_VERSION="2.4.7-1.2ubuntu7.3" # https://packages.ubuntu.com/noble/libcups2t64
ARG LIBDRM2_VERSION="2.4.122-1~ubuntu0.24.04.1" # https://packages.ubuntu.com/noble-updates/libdrm2
ARG LIBFONTCONFIG1_VERSION="2.15.0-1.1ubuntu2" # https://packages.ubuntu.com/noble/libfontconfig1
ARG LIBFRIBIDI0_VERSION="1.0.13-3build1" # https://packages.ubuntu.com/noble/libfribidi0
ARG LIBGBM1_VERSION="24.0.5-1ubuntu1" # https://packages.ubuntu.com/noble/libgbm1
ARG LIBGDK_PIXBUF_2_0_0_VERSION="2.42.10+dfsg-3ubuntu3.2" # https://packages.ubuntu.com/noble/libgdk-pixbuf-2.0-0
ARG LIBGL1_VERSION="1.7.0-1build1" # https://packages.ubuntu.com/noble/libgl1
ARG LIBGLIB2_0_0T64_VERSION="2.80.0-6ubuntu3.4" # https://packages.ubuntu.com/noble/libglib2.0-0t64
ARG LIBGSTREAMER_PLUGINS_BASE1_0_0_VERSION="1.24.2-1ubuntu0.2" # https://packages.ubuntu.com/noble/libgstreamer-plugins-base
ARG LIBGSTREAMER1_0_0_VERSION="1.24.2-1ubuntu0.1" # https://packages.ubuntu.com/noble/libgstreamer1.0-0
ARG LIBGTK_3_0T64_VERSION="3.24.41-4ubuntu1.1" # https://packages.ubuntu.com/noble/libgtk-3-0t64
ARG LIBGTK2_0_0T64_VERSION="2.24.33-4ubuntu1.1" # https://packages.ubuntu.com/noble/libgtk2.0-0t64
ARG LIBICE6_VERSION="2:1.0.10-1build3" # https://packages.ubuntu.com/noble/libice6
ARG LIBLTDL7_VERSION="2.4.7-7build1" # https://packages.ubuntu.com/noble/libltdl7
ARG LIBNETTLE8T64_VERSION="3.9.1-2.2build1.1" # https://packages.ubuntu.com/noble-updates/libnettle8t64
ARG LIBNSPR4_VERSION="2:4.35-1.1build1" # https://packages.ubuntu.com/noble/libnspr4
ARG LIBNSS3_VERSION="2:3.98-1build1" # https://packages.ubuntu.com/noble/libnss3
ARG LIBPAM0G_VERSION="1.5.3-5ubuntu5.4" # https://packages.ubuntu.com/noble/libpam0g
ARG LIBPANGO_1_0_0_VERSION="1.52.1+ds-1build1" # https://packages.ubuntu.com/noble/libpango-1.0-0
ARG LIBPANGOCAIRO_1_0_0_VERSION="1.52.1+ds-1build1" # https://packages.ubuntu.com/noble/libpangocairo-1.0-0
ARG LIBPANGOFT2_1_0_0_VERSION="1.52.1+ds-1build1" # https://packages.ubuntu.com/noble/libpangoft2-1.0-0
ARG LIBPIXMAN_1_0_VERSION="0.42.2-1build1" # https://packages.ubuntu.com/noble/libpixman-1-0
ARG LIBSNDFILE1_VERSION="1.2.2-1ubuntu5.24.04.1" # https://packages.ubuntu.com/noble/libsndfile1
ARG LIBTIRPC3T64_VERSION="1.3.4+ds-1.1build1" # https://packages.ubuntu.com/noble/libtirpc3t64
ARG LIBUUID1_VERSION="2.39.3-9ubuntu6.3" # https://packages.ubuntu.com/noble-updates/libuuid1
ARG LIBWAYLAND_CLIENT0_VERSION="1.22.0-2.1build1" # https://packages.ubuntu.com/noble/libwayland-client0
ARG LIBXCOMPOSITE1_VERSION="1:0.4.5-1build3" # https://packages.ubuntu.com/noble/libxcomposite1
ARG LIBXCURSOR1_VERSION="1:1.2.1-1build1" # https://packages.ubuntu.com/noble/libxcursor1
ARG LIBXDAMAGE1_VERSION="1:1.1.6-1build1" # https://packages.ubuntu.com/noble/libxdamage1
ARG LIBXFIXES3_VERSION="1:6.0.0-2build1" # https://packages.ubuntu.com/noble/libxfixes3
ARG LIBXFONT2_VERSION="1:2.0.6-1build1" # https://packages.ubuntu.com/noble/libxfont2
ARG LIBXFT2_VERSION="2.3.6-1build1" # https://packages.ubuntu.com/noble/libxft2
ARG LIBXINERAMA1_VERSION="2:1.1.4-3build1" # https://packages.ubuntu.com/noble/libxinerama1
ARG LIBXRANDR2_VERSION="2:1.5.2-2build1" # https://packages.ubuntu.com/noble/libxrandr2
ARG LIBXT6T64_VERSION="1:1.2.1-1.2build1" # https://packages.ubuntu.com/noble/libxt6t64
ARG LIBXTST6_VERSION="2:1.2.3-1.1build1" # https://packages.ubuntu.com/noble/libxtst6
ARG LIBXXF86VM1_VERSION="1:1.1.4-1build4" # https://packages.ubuntu.com/noble/libxxf86vm1
ARG NET_TOOLS_VERSION="2.10-0.1ubuntu4.4" # https://packages.ubuntu.com/noble/net-tools
ARG PROCPS_VERSION="2:4.0.4-4ubuntu3.2" # https://packages.ubuntu.com/noble-updates/procps
ARG UNZIP_VERSION="6.0-28ubuntu4.1" # https://packages.ubuntu.com/noble/unzip
ARG ZLIB1G_VERSION="1:1.3.dfsg-3.1ubuntu2.1" # https://packages.ubuntu.com/noble-updates/zlib1g

# Base Install to download and process applications.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    curl=${CURL_VERSION} \
    ca-certificates=${CA_CERTIFICATES_VERSION} \
    unzip=${UNZIP_VERSION} \
    # Clean up and remove cache to reduce the image size.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Get and install the R2024a matlab runtime.    
# https://uk.mathworks.com/products/compiler/matlab-runtime.html
RUN curl -L0 --output matlab_runtime.zip https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/7/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_7_glnxa64.zip \
    && unzip matlab_runtime.zip -d matlab_runtime \
    && ./matlab_runtime/install -destinationFolder /opt/matlabruntime -agreeToLicense yes \ 
    && rm matlab_runtime.zip \ 
    && rm -rf matlab_runtime

# Get and install the MIB2 for the R2024a matlab runtime.
# The files are placed on the github repo: https://github.com/Ajaxels/MIB2/
RUN curl -L0 --output MIB2.zip  https://github.com/Ajaxels/MIB2/releases/download/v2.91/MIB2_Linux_29102_files_R2024a.zip \
    && unzip MIB2.zip -d /mib2 \
    && rm MIB2.zip \
    && apt-get purge curl -y 

# Matlab Runtime  Requirements from https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-runtime-deps/r2024a/ubuntu22.04
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates=${CA_CERTIFICATES_VERSION} \
    gstreamer1.0-plugins-base=${GSTREAMER1_0_PLUGINS_BASE_VERSION} \
    gstreamer1.0-plugins-good=${GSTREAMER1_0_PLUGINS_GOOD_VERSION} \
    gstreamer1.0-tools=${GSTREAMER1_0_TOOLS_VERSION} \
    libasound2t64=${LIBASOUND2T64_VERSION} \
    libatomic1=${LIBATOMIC1_VERSION} \
    libc6=${LIBC6_VERSION} \
    libcairo-gobject2=${LIBCAIRO_GOBJECT2_VERSION} \
    libcairo2=${LIBCAIRO2_VERSION} \
    libcap2=${LIBCAP2_VERSION} \
    libcups2t64=${LIBCUPS2T64_VERSION} \
    libdrm2=${LIBDRM2_VERSION} \
    libfontconfig1=${LIBFONTCONFIG1_VERSION} \
    libfribidi0=${LIBFRIBIDI0_VERSION} \
    libgbm1=${LIBGBM1_VERSION} \
    libgdk-pixbuf-2.0-0=${LIBGDK_PIXBUF_2_0_0_VERSION} \
    libgl1=${LIBGL1_VERSION} \
    libglib2.0-0t64=${LIBGLIB2_0_0T64_VERSION} \
    libgstreamer-plugins-base1.0-0=${LIBGSTREAMER_PLUGINS_BASE1_0_0_VERSION} \
    libgstreamer1.0-0=${LIBGSTREAMER1_0_0_VERSION} \
    libgtk-3-0t64=${LIBGTK_3_0T64_VERSION} \
    libgtk2.0-0t64=${LIBGTK2_0_0T64_VERSION} \
    libice6=${LIBICE6_VERSION} \
    libltdl7=${LIBLTDL7_VERSION} \
    libnettle8t64=${LIBNETTLE8T64_VERSION} \
    libnspr4=${LIBNSPR4_VERSION} \
    libnss3=${LIBNSS3_VERSION} \
    libpam0g=${LIBPAM0G_VERSION} \
    libpango-1.0-0=${LIBPANGO_1_0_0_VERSION} \
    libpangocairo-1.0-0=${LIBPANGOCAIRO_1_0_0_VERSION} \
    libpangoft2-1.0-0=${LIBPANGOFT2_1_0_0_VERSION} \
    libpixman-1-0=${LIBPIXMAN_1_0_VERSION} \
    libsndfile1=${LIBSNDFILE1_VERSION} \
    libtirpc3t64=${LIBTIRPC3T64_VERSION} \
    libuuid1=${LIBUUID1_VERSION} \
    libwayland-client0=${LIBWAYLAND_CLIENT0_VERSION} \
    libxcomposite1=${LIBXCOMPOSITE1_VERSION} \
    libxcursor1=${LIBXCURSOR1_VERSION} \
    libxdamage1=${LIBXDAMAGE1_VERSION} \
    libxfixes3=${LIBXFIXES3_VERSION} \
    libxfont2=${LIBXFONT2_VERSION} \
    libxft2=${LIBXFT2_VERSION} \
    libxinerama1=${LIBXINERAMA1_VERSION} \
    libxrandr2=${LIBXRANDR2_VERSION} \
    libxt6t64=${LIBXT6T64_VERSION} \
    libxtst6=${LIBXTST6_VERSION} \
    libxxf86vm1=${LIBXXF86VM1_VERSION} \
    net-tools=${NET_TOOLS_VERSION} \
    procps=${PROCPS_VERSION} \
    unzip=${UNZIP_VERSION} \
    zlib1g=${ZLIB1G_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# A fix to ensure that MIB2 runs.

# https://github.com/mohammaddehnavi/mohi-docs/blob/main/Matlab/README.md#fix-install-matlab    
RUN mkdir /opt/matlabruntime/R2024a/sys/os/glnxa64/exclude \
    && mv /opt/matlabruntime/R2024a/sys/os/glnxa64/libstdc++.so.6 /opt/matlabruntime/R2024a/sys/os/glnxa64/libstdc++.so.6.0.28 /opt/matlabruntime/R2024a/sys/os/glnxa64/exclude

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/matlabruntime/R2024a/runtime/glnxa64:/opt/matlabruntime/R2024a/bin/glnxa64:/opt/matlabruntime/R2024a/sys/os/glnxa64:/opt/matlabruntime/R2024a/sys/opengl/lib/glnxa64"

CMD ["/mib2/MIB"]
