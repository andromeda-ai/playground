# Use arguments to determine whether to build a CPU or GPU image
ARG BASE_IMAGE

# Set the base image based on the argument
FROM ${BASE_IMAGE}

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

# Enable systemd
RUN systemctl enable ssh

# Expose SSH port
EXPOSE 22

# Add a script to add an SSH user with a provided public key
COPY startup_script.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup_script.sh

# Install NVIDIA NCCL (only for GPU image)
RUN if [ "${BASE_IMAGE}" = "nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04" ]; then \
    apt-get update && apt-get install -y --no-install-recommends --allow-change-held-packages \
    libnccl2 \
    libnccl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*; \
fi

# Install Python libraries and ML tools (only for GPU image)
RUN if [ "${BASE_IMAGE}" = "nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04" ]; then \
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
fi

# Install additional GPU tools (only for GPU image)
RUN if [ "${BASE_IMAGE}" = "nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04" ]; then \
    pip3 install --no-cache-dir \
    nvitop \
    py3nvml \
    pynvml; \
fi

# Install benchmarking tools (only for GPU image)
RUN if [ "${BASE_IMAGE}" = "nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04" ]; then \
    pip3 install --no-cache-dir \
    pytest-benchmark \
    memory_profiler \
    line_profiler; \
fi

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/startup_script.sh"]
