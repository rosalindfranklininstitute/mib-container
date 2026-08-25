FROM containers.mathworks.com/matlab-runtime:r2026a-full AS mib

ENV AGREE_TO_MATLAB_RUNTIME_LICENSE="yes"
ENV LD_LIBRARY_PATH="/opt/matlabruntime/R2026a/runtime/glnxa64:/opt/matlabruntime/R2026a/bin/glnxa64:/opt/matlabruntime/R2026a/sys/os/glnxa64:/opt/matlabruntime/R2026a/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2026a/extern/bin/glnxa64"

# Install MIB3 from local files
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY MIB3_Linux_20260820_files.zip /tmp/
RUN unzip /tmp/MIB3_Linux_20260820_files.zip \
    && mv deployed/linux/files /mib3 \
    && rm -rf linux /tmp/MIB3_Linux_20260820_files.zip

FROM mib AS mib-sam

# Segment Anything Model 2
# Uses the MIB-forked distribution: https://github.com/Ajaxels/segment-anything-2
# Installation follows: https://mib.helsinki.fi/downloads_systemreq_sam2.html
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda \
    && rm /tmp/miniconda.sh \
    && /opt/miniconda/bin/conda config --remove channels defaults \
    && /opt/miniconda/bin/conda config --add channels conda-forge

# Create the sam4mib conda environment with Python 3.11
RUN /opt/miniconda/bin/conda create -n sam4mib python=3.11 pip -y --override-channels -c conda-forge

# Enable environment
ENV PATH="/opt/miniconda/envs/sam4mib/bin:$PATH"
ENV CONDA_PREFIX="/opt/miniconda/envs/sam4mib"
ENV CONDA_DEFAULT_ENV="sam4mib"

# Install dependencies via pip
RUN /opt/miniconda/envs/sam4mib/bin/pip install --no-cache-dir torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121 \
    && /opt/miniconda/envs/sam4mib/bin/pip install --no-cache-dir hydra-core iopath

# Clone the MIB fork of segment-anything-2
RUN git clone https://github.com/Ajaxels/segment-anything-2.git /opt/segment-anything-2

# Install segment-anything-2 as editable package into the conda environment
RUN /opt/miniconda/envs/sam4mib/bin/pip install -e /opt/segment-anything-2

# Copy yaml config files from subdirectories into the main sam2 directory
# as required (Linux) https://mib.helsinki.fi/downloads_systemreq_sam2.html
RUN cp -n /opt/segment-anything-2/sam2/configs/sam2/*.yaml \
       /opt/segment-anything-2/sam2/ \
    && cp -n /opt/segment-anything-2/sam2/configs/sam2.1/*.yaml \
       /opt/segment-anything-2/sam2/

# Get default tiny SAM2 models (switching to 2.1 base_plus or l model recommended)
RUN curl -L -o /tmp/sam2_hiera_tiny.pt \
    https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_tiny.pt \
    && curl -L -o /tmp/sam2_hiera_t.yaml \
    https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_t.yaml

# BM3D and BM4D filters legacy releases (2021/2015). Non-profit education /
# research license: https://webpages.tuni.fi/foi/GCF-BM3D/legal_notice.html
RUN mkdir -p /opt/BMxD/BM3D /opt/BMxD/BM4D \
    && curl -L -o /tmp/bm3d.zip https://webpages.tuni.fi/foi/GCF-BM3D/BM3D.zip \
    && curl -L -o /tmp/bm4d.zip https://webpages.tuni.fi/foi/GCF-BM3D/BM4D_v3p2.zip \
    && unzip /tmp/bm3d.zip -d /opt/BMxD/BM3D \
    && unzip /tmp/bm4d.zip -d /opt/BMxD/BM4D \
    && rm /tmp/bm3d.zip /tmp/bm4d.zip

# Copy saved MIB preferences (Python, BM3D/BM4D and SAM2 paths)
# Used by root (docker) only
COPY Matlab /root/Matlab

CMD ["/mib3/MIB3"]

