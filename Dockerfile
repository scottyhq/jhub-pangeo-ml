# Need base image with CUDA libraries
FROM nvidia/cuda:10.1-cudnn7-devel

# JuptyterHub config
ARG NB_USER=jovyan
ARG NB_UID=1000

ENV USER=${NB_USER} \ 
    NB_UID=${NB_UID} \
    HOME=/home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Miniconda config
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV MINICONDA_VERSION=4.7.12 \
    CONDA_DIR=/opt/conda 

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p ${CONDA_DIR} \
    && rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && chown -R ${NB_USER}:${NB_USER} ${CONDA_DIR}

# Creat conda environment
COPY environment.yaml /tmp/environment.yaml

USER ${NB_USER}

ENV PATH=${CONDA_DIR}/bin:$PATH

RUN conda env create --quiet \
    -f /tmp/environment.yaml \
    && conda clean --all -f -y \
