# Use arguments to determine whether to build a CPU or GPU image
ARG BASE_IMAGE

# Set the base image based on the argument
FROM ${BASE_IMAGE}
ARG GPU_IMAGE=false

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Install gnupg
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install system utilities and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    htop \
    iotop \
    ncdu \
    fio \
    openssh-server \
    python3-pip \
    rsync \
    screen \
    sysstat \
    tmux \
    wget \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install OpenSSH server
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    adcli \
    dbus \
    libnss-sss \
    libpam-sss \
    openssh-server \
    realmd \
    sssd \
    sssd-ad \
    sssd-tools \
    sudo \
    systemd \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install YubiKey PAM module
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    libpam-yubico \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable systemd
RUN systemctl enable ssh

# Expose SSH port
EXPOSE 22

# Add a script to add an SSH user with a provided public key
COPY startup_script.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup_script.sh

# Install NVIDIA NCCL (only for GPU image)
RUN if [ "${GPU_IMAGE}" = "true" ]; then \
    apt-get update && apt-get install -y --no-install-recommends --allow-change-held-packages \
    libnccl2 \
    libnccl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*; \
else \
    echo "GPU_IMAGE is not set to true, skipping NVIDIA NCCL installation."; \
fi

# Install NVIDIA DCGM (only for GPU image)
RUN if [ "${GPU_IMAGE}" = "true" ]; then \
    apt-key del 7fa2af80 \
    && distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g') \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/sbsa/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-change-held-packages \
    datacenter-gpu-manager \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*; \
else \
    echo "GPU_IMAGE is not set to true, skipping NVIDIA DCGM installation."; \
fi

# Install Python libraries and ML tools (only for GPU image)
RUN if [ "${GPU_IMAGE}" = "true" ]; then \
    pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy \
    pandas \
    scikit-learn \
    scipy \
    matplotlib \
    seaborn \
    jupyter \
    jupyterlab \
    torch \
    torchvision \
    torchaudio \
    transformers \
    datasets \
    opencv-python-headless \
    mlflow \
    wandb \
    ray[tune] \
    optuna; \
else \
    echo "GPU_IMAGE is not set to true, skipping Python libraries and ML tools installation."; \
fi

# Install additional GPU tools (only for GPU image)
RUN if [ "${GPU_IMAGE}" = "true" ]; then \
    pip3 install --no-cache-dir \
    nvitop \
    py3nvml \
    pynvml; \
else \
    echo "GPU_IMAGE is not set to true, skipping additional GPU tools installation."; \
fi

# Install benchmarking tools (only for GPU image)
RUN if [ "${GPU_IMAGE}" = "true" ]; then \
    pip3 install --no-cache-dir \
    pytest-benchmark \
    memory_profiler \
    line_profiler; \
else \
    echo "GPU_IMAGE is not set to true, skipping benchmarking tools installation."; \
fi

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/startup_script.sh"]
