ARG MATLAB_RELEASE=R2026a
ARG MATLAB_RELEASE_LC=r2026a
ARG MIB_VERSION=2026.10
# Must contain ${MIB_VERSION}_${MATLAB_RELEASE} e.g. 2026-10_R2026a
ARG MIB_URL=https://github.com/Ajaxels/MIB3/releases/download/v2026.10.0/MIB3_Linux_2026-10_R2026a_files.zip
ARG PYTHON_VERSION=3.11
# MIB-tested fork of segment-anything-2 (commit sha)
ARG SAM2_REF=6063f236007ea02e4f97221d87c20b6547aebf4f
# Torch index (torch version auto-resolved by pip). MATLAB R2026a ships CUDA 12.8.
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128

# Matabl runtime base (sets LD_LIBRARY_PATH, TZ=Etc/UTC and DEBIAN_FRONTEND=noninteractive)
FROM containers.mathworks.com/matlab-runtime:${MATLAB_RELEASE_LC}-full AS base

# MIB build layer
FROM base AS mib-builder
ARG MIB_VERSION
ARG MATLAB_RELEASE
ARG MIB_URL
ARG MIB_SHA256

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN case "${MIB_URL}" in \
        *"$(echo "${MIB_VERSION}" | tr . -)_${MATLAB_RELEASE}"*) ;; \
        *) echo "MIB_URL does not match MIB_VERSION=${MIB_VERSION} / MATLAB_RELEASE=${MATLAB_RELEASE}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/mib.zip "${MIB_URL}" \
    && unzip -q /tmp/mib.zip -d /tmp/mib \
    && MIB_BIN="$(find /tmp/mib -type f -name MIB3)" \
    && [ -n "${MIB_BIN}" ] && [ "$(echo "${MIB_BIN}" | wc -l)" = 1 ] \
    && mv "$(dirname "${MIB_BIN}")" /mib3 \
    && rm -rf /tmp/mib /tmp/mib.zip

# SAM2 build layer
FROM base AS sam-builder
ARG PYTHON_VERSION
ARG SAM2_REF
ARG TORCH_INDEX_URL

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Miniforge
RUN curl -fsSL -o /tmp/miniforge.sh \
        https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
    && bash /tmp/miniforge.sh -b -p /opt/miniforge3 \
    && rm /tmp/miniforge.sh \
    && /opt/miniforge3/bin/conda create -y -n sam4mib python=${PYTHON_VERSION} pip \
    && /opt/miniforge3/bin/conda clean -afy

ENV PATH="/opt/miniforge3/envs/sam4mib/bin:${PATH}"

RUN python -m pip install --no-cache-dir torch torchvision --index-url "${TORCH_INDEX_URL}" \
    && python -m pip install --no-cache-dir hydra-core iopath

# Copy .yaml configs as explaining in installation docs
RUN git clone https://github.com/Ajaxels/segment-anything-2.git /opt/segment-anything-2 \
    && git -C /opt/segment-anything-2 checkout "${SAM2_REF}" \
    && git -C /opt/segment-anything-2 rev-parse HEAD \
    && python -m pip install --no-cache-dir -e /opt/segment-anything-2 \
    && cp -n /opt/segment-anything-2/sam2/configs/sam2/*.yaml /opt/segment-anything-2/sam2/ \
    && cp -n /opt/segment-anything-2/sam2/configs/sam2.1/*.yaml /opt/segment-anything-2/sam2/ \
    && rm -rf /opt/segment-anything-2/.git

# Install default tiny models 
RUN mkdir -p /opt/segment-anything-2/checkpoints \
    && curl -fsSL -o /opt/segment-anything-2/checkpoints/sam2_hiera_tiny.pt \
        https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_tiny.pt \
    && sha256sum /opt/segment-anything-2/checkpoints/sam2_hiera_tiny.pt

# Final layer
FROM base AS prod
ARG MATLAB_RELEASE

COPY --from=mib-builder /mib3 /mib3
COPY --from=sam-builder /opt/miniforge3/envs/sam4mib /opt/miniforge3/envs/sam4mib
COPY --from=sam-builder /opt/segment-anything-2 /opt/segment-anything-2

ENV PATH="/opt/miniforge3/envs/sam4mib/bin:${PATH}" \
    CONDA_PREFIX="/opt/miniforge3/envs/sam4mib" \
    CONDA_DEFAULT_ENV="sam4mib"

# Check matlab dir and mib executable is not missing libraries
RUN test -d "/opt/matlabruntime/${MATLAB_RELEASE}" \
    && test -x /mib3/MIB3 \
    && ! ldd /mib3/MIB3 | grep "not found"
# Import test for sam/torch tools
RUN python -m pip check \
    && python -c "import torch, torchvision, hydra, iopath, sam2; print('torch', torch.__version__, 'cuda', torch.version.cuda, torch.cuda.get_arch_list())"
RUN python -c "from sam2.build_sam import build_sam2; build_sam2('sam2_hiera_t.yaml', '/opt/segment-anything-2/checkpoints/sam2_hiera_tiny.pt', device='cpu'); print('SAM2 tiny loads')"

# Copy saved MIB2 preferences (Python and SAM2 paths)
COPY Matlab /root/Matlab

CMD ["/mib3/MIB3"]

# Metadata
ARG MATLAB_RELEASE_LC
ARG MIB_VERSION
ARG MIB_URL
ARG MIB_SHA256
ARG PYTHON_VERSION
ARG SAM2_REF
ARG TORCH_INDEX_URL
ARG IMAGE_VERSION="${MIB_VERSION}-${MATLAB_RELEASE}"
ARG IMAGE_REVISION=""
ARG IMAGE_CREATED=""

LABEL org.opencontainers.image.title="RFI/CCP-volumeEM MIB3 with SAM2" \
      org.opencontainers.image.description="Microscopy Image Browser 3 (Linux compiled, MATLAB Runtime) with a Python environment for Segment Anything 2" \
      org.opencontainers.image.authors="The Rosalind Franklin Institute, The Collaborative Computational Project for Volume Electron Microscopy" \
      org.opencontainers.image.source="https://github.com/rosalindfranklininstitute/mib-container" \
      org.opencontainers.image.documentation="https://rosalindfranklininstitute.github.io/volume-em-container-documentation/software/mib2/" \
      org.opencontainers.image.licenses="GPL-3.0-only AND LGPL-2.1-only AND LGPL-2.1-or-later AND Apache-2.0 AND BSD-3-Clause AND MIT AND MPL-2.0 AND Python-2.0 AND LicenseRef-MIB-Standalone AND LicenseRef-MATLAB-Runtime AND LicenseRef-NVIDIA-CUDA" \
      org.opencontainers.image.base.name="containers.mathworks.com/matlab-runtime:${MATLAB_RELEASE_LC}-full" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      uk.ac.rfi.mib.version="${MIB_VERSION}" \
      uk.ac.rfi.mib.url="${MIB_URL}" \
      uk.ac.rfi.matlab.runtime.release="${MATLAB_RELEASE}" \
      uk.ac.rfi.python.version="${PYTHON_VERSION}" \
      uk.ac.rfi.sam2.repository="https://github.com/Ajaxels/segment-anything-2" \
      uk.ac.rfi.sam2.ref="${SAM2_REF}" \
      uk.ac.rfi.torch.index.url="${TORCH_INDEX_URL}"
