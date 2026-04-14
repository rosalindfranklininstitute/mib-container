ARG UBUNTU_VERSION=24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/London

FROM ubuntu:${UBUNTU_VERSION} AS matlab

# Base Install to download and process applications.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    # Clean up and remove cache to reduce the image size.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Matlab Runtime Requirements from https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-runtime-deps/r2024a/ubuntu22.04
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    libasound2t64 \
    libatomic1 \
    libc6 \
    libcairo-gobject2 \
    libcairo2 \
    libcap2 \
    libcups2t64 \
    libdrm2 \
    libfontconfig1 \
    libfribidi0 \
    libgbm1 \
    libgdk-pixbuf-2.0-0 \
    libgl1 \
    libglib2.0-0t64 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 \
    libgtk-3-0t64 \
    libgtk2.0-0t64 \
    libice6 \
    libltdl7 \
    libnettle8t64 \
    libnspr4 \
    libnss3 \
    libpam0g \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libpixman-1-0 \
    libsndfile1 \
    libtirpc3t64 \
    libuuid1 \
    libwayland-client0 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxfont2 \
    libxft2 \
    libxinerama1 \
    libxrandr2 \
    libxt6t64 \
    libxtst6 \
    libxxf86vm1 \
    net-tools \
    procps \
    unzip \
    zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R2024a matlab runtime
# https://uk.mathworks.com/products/compiler/matlab-runtime.html
RUN curl -L0 --output matlab_runtime.zip https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/7/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_7_glnxa64.zip \
    && unzip matlab_runtime.zip -d matlab_runtime \
    && ./matlab_runtime/install -destinationFolder /opt/matlabruntime -agreeToLicense yes \ 
    && rm matlab_runtime.zip \ 
    && rm -rf matlab_runtime

FROM matlab AS mib

# Install MIB2 for R2024a runtime
# https://github.com/Ajaxels/MIB2/
RUN curl -L0 --output MIB2.zip  https://github.com/Ajaxels/MIB2/releases/download/v2.91/MIB2_Linux_29102_files_R2024a.zip \
    && unzip MIB2.zip -d /mib2 \
    && rm MIB2.zip \
    && apt-get purge curl -y 

# A fix to ensure that MIB2 runs.
# https://github.com/mohammaddehnavi/mohi-docs/blob/main/Matlab/README.md#fix-install-matlab    
RUN mkdir /opt/matlabruntime/R2024a/sys/os/glnxa64/exclude \
    && mv /opt/matlabruntime/R2024a/sys/os/glnxa64/libstdc++.so.6 /opt/matlabruntime/R2024a/sys/os/glnxa64/libstdc++.so.6.0.28 /opt/matlabruntime/R2024a/sys/os/glnxa64/exclude

ENV LD_LIBRARY_PATH="/opt/matlabruntime/R2024a/runtime/glnxa64:/opt/matlabruntime/R2024a/bin/glnxa64:/opt/matlabruntime/R2024a/sys/os/glnxa64:/opt/matlabruntime/R2024a/sys/opengl/lib/glnxa64"

FROM mib AS mib-sam

# Segment Anything Model 2
# Use forked distribution checked against MIB: https://github.com/Ajaxels/segment-anything-2
# Installation follows https://mib.helsinki.fi/downloads_systemreq_sam2.html
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    python3-full \
    python3-pip \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    libpython3.11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
 
# Create the sam4mib virtual environment using Python 3.11 (required by MATLAB R2024a)
RUN python3.11 -m venv /opt/sam4mib

# Enable venv
ENV PATH="/opt/sam4mib/bin:$PATH"

# Install requirements for segment-anything-2 use into venv 
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --no-cache-dir hydra-core iopath

# Clone the MIB fork of segment-anything-2 (N.B. No pip install)
RUN git clone https://github.com/Ajaxels/segment-anything-2.git /opt/segment-anything-2
 
# Linux fix: copy yaml config files from subdirectories into the main sam2 directory,
# as required by https://mib.helsinki.fi/downloads_systemreq_sam2.html
RUN cp -n /opt/segment-anything-2/sam2/configs/sam2/*.yaml \
       /opt/segment-anything-2/sam2/ \
    && cp -n /opt/segment-anything-2/sam2/configs/sam2.1/*.yaml \
       /opt/segment-anything-2/sam2/

# Copy saved MIB2 preferences (Python and SAM2 paths) 
COPY Matlab /root/Matlab
# Get default SAM2 models
RUN wget -q -P /tmp/ \
    https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_tiny.pt \
    && wget -q -P /tmp/ \
    https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_tiny.yaml

CMD ["/mib2/MIB"]

