ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/London

FROM ubuntu:24.04 AS matlab

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# MATLAB Runtime dependencies
# https://github.com/mathworks-ref-arch/container-images/tree/main/matlab-runtime-deps/r2024a/ubuntu22.04
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

# Install MATLAB Runtime R2024a
RUN curl -L0 --output matlab_runtime.zip https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/7/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_7_glnxa64.zip \
    && unzip matlab_runtime.zip -d matlab_runtime \
    && ./matlab_runtime/install -destinationFolder /opt/matlabruntime -agreeToLicense yes \
    && rm matlab_runtime.zip \
    && rm -rf matlab_runtime

FROM matlab AS mib

# Install MIB2 for R2024a runtime
# https://github.com/Ajaxels/MIB2/
RUN curl -L0 --output MIB2.zip https://github.com/Ajaxels/MIB2/releases/download/v2.91/MIB2_Linux_29102_files_R2024a.zip \
    && unzip MIB2.zip -d /mib2 \
    && rm MIB2.zip

# Fix for MIB2 runtime
# https://github.com/mohammaddehnavi/mohi-docs/blob/main/Matlab/README.md#fix-install-matlab
RUN mkdir /opt/matlabruntime/R2024a/sys/os/glnxa64/exclude \
    && mv /opt/matlabruntime/R2024a/sys/os/glnxa64/libstdc++.so.6 \
          /opt/matlabruntime/R2024a/sys/os/glnxa64/libstdc++.so.6.0.28 \
          /opt/matlabruntime/R2024a/sys/os/glnxa64/exclude

ENV LD_LIBRARY_PATH="/opt/matlabruntime/R2024a/runtime/glnxa64:/opt/matlabruntime/R2024a/bin/glnxa64:/opt/matlabruntime/R2024a/sys/os/glnxa64:/opt/matlabruntime/R2024a/sys/opengl/lib/glnxa64"

FROM mib AS mib-sam

# Segment Anything Model 2
# Use forked distribution checked against MIB: https://github.com/Ajaxels/segment-anything-2
# Installation follows https://mib.helsinki.fi/downloads_systemreq_sam2.html
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Miniforge3 (conda) to the path documented by MIB
RUN curl -L -o /tmp/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
    && bash /tmp/miniforge.sh -b -p /opt/miniforge3 \
    && rm /tmp/miniforge.sh

# Create sam4mib conda environment with Python 3.11
# Using documented path: /opt/miniforge3/envs/sam4mib
RUN /opt/miniforge3/bin/conda create -y --prefix /opt/miniforge3/envs/sam4mib python=3.11 \
    && /opt/miniforge3/bin/conda clean -afy

# Install SAM2 dependencies into conda env
RUN /opt/miniforge3/envs/sam4mib/bin/pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && /opt/miniforge3/envs/sam4mib/bin/pip install --no-cache-dir hydra-core iopath

# Clone MIB fork of segment-anything-2 into documented Linux location
RUN git clone https://github.com/Ajaxels/segment-anything-2.git \
    /opt/miniforge3/envs/sam4mib/lib/python3.11/site-packages/segment-anything-2

# Linux fix: copy yaml configs as required by MIB documentation
RUN cp -n /opt/miniforge3/envs/sam4mib/lib/python3.11/site-packages/segment-anything-2/sam2/configs/sam2/*.yaml \
          /opt/miniforge3/envs/sam4mib/lib/python3.11/site-packages/segment-anything-2/sam2/ \
    && cp -n /opt/miniforge3/envs/sam4mib/lib/python3.11/site-packages/segment-anything-2/sam2/configs/sam2.1/*.yaml \
          /opt/miniforge3/envs/sam4mib/lib/python3.11/site-packages/segment-anything-2/sam2/

# Get default SAM2 models
RUN curl -L -o /tmp/sam2_hiera_tiny.pt \
    https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_tiny.pt \
    && curl -L -o /tmp/sam2_hiera_t.yaml \
    https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_t.yaml

# BM3D and BM4D filters for image denoising - LEGACY releases (2021/2015)
# License: https://webpages.tuni.fi/foi/GCF-BM3D/legal_notice.html
# Non-profit education / research use only
RUN mkdir -p /opt/BMxD/BM3D /opt/BMxD/BM4D \
    && curl -L -o /tmp/bm3d.zip https://webpages.tuni.fi/foi/GCF-BM3D/BM3D.zip \
    && curl -L -o /tmp/bm4d.zip https://webpages.tuni.fi/foi/GCF-BM3D/BM4D_v3p2.zip \
    && unzip /tmp/bm3d.zip -d /opt/BMxD/BM3D \
    && unzip /tmp/bm4d.zip -d /opt/BMxD/BM4D \
    && rm /tmp/bm3d.zip /tmp/bm4d.zip

# Copy saved MIB2 preferences (Python, BM3D/BM4D and SAM2 paths)
COPY Matlab /root/Matlab

ENV PATH="/opt/miniforge3/envs/sam4mib/bin:/opt/miniforge3/bin:$PATH"

CMD ["/mib2/MIB"]
