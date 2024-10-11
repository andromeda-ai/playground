### Dockerfile Repository: `playground`

This repository contains Dockerfiles to build playground images based on the latest Ubuntu distribution and NVIDIA's CUDA base image. These images include various tools for monitoring, data transfer, cloud service command-line interfaces (CLIs), and more.

#### Docker Images:

- **CPU Image**: Based on the latest Ubuntu distribution, this image includes essential tools for system monitoring, data transfer, session management, and cloud service CLIs.
- **GPU Image**: Based on NVIDIA's CUDA base image, this image is designed for machine learning and GPU-intensive tasks, including additional Python libraries and ML frameworks.

#### Tools Included:

- **Filesystem/Memory/Disk Tools:**
  - `htop`: Interactive process viewer
  - `iotop`: Monitor I/O usage by processes
  - `sysstat`: System performance monitoring tools
  - `ncdu`: Disk usage analyzer with an interactive interface

- **Data Transfer Tools:**
  - `rsync`: Efficient file transfer and synchronization tool

- **Session Management Tools:**
  - `tmux`: Terminal multiplexer
  - `screen`: Full-screen window manager

- **Cloud Service CLIs:**
  - **Google Cloud SDK:**
    - Includes dependencies and the Google Cloud CLI
  - **Azure CLI:**
    - Installed using the official script from Microsoft

- **Additional Tools** (in both images):
  - `curl`, `git`, `wget`: Essential command-line tools
  - `zsh`: Shell with advanced features
  - **OpenSSH Server**: For secure shell access

- **Machine Learning and GPU Tools** (in Playground Image):
  - Python libraries: `numpy`, `pandas`, `scikit-learn`, `scipy`, `matplotlib`, `seaborn`
  - ML frameworks: `torch`, `torchvision`, `torchaudio`, `transformers`, `datasets`
  - Jupyter: `jupyter`, `jupyterlab`
  - MLflow, Weights & Biases: `mlflow`, `wandb`
  - Optimization and tuning: `ray[tune]`, `optuna`
  - GPU tools: `nvitop`, `py3nvml`, `pynvml`
  - Benchmarking tools: `pytest-benchmark`, `memory_profiler`, `line_profiler`

#### Usage:

To build the **CPU Image** using the Ubuntu-based Dockerfile, use the following command in the directory containing the Dockerfile:

```bash
make build-cpu
```

To build the **Playground Image** using the CUDA-based Dockerfile, use the following command:

```bash
make build-gpu
```

**Important:** Each time you build the images, the version will be updated to ensure you have the latest tools and dependencies. This is achieved through the Makefile, which dynamically sets the version based on the build process.

#### Note:

- The Utility Image is based on the latest Ubuntu distribution.
- The Playground Image is based on NVIDIA's CUDA base image.
- The default command (`CMD`) is set to launch the bash shell.
- The images expose port 22 for SSH access.

Feel free to customize the Dockerfiles according to your specific requirements.

#### Contributing:

Contributions are welcome! Feel free to open issues or submit pull requests.
