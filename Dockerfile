# Start from NVIDIA CUDA 11.8 base image
FROM nvidia/cuda:11.8.0-base-ubuntu20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Miniconda
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# Add conda to path
ENV PATH=$CONDA_DIR/bin:$PATH

# Copy environment.yml file
COPY environment.yml .

# Create conda environment from yml file
RUN conda env create -f environment.yml

# Create a script that will extract environment name and activate it
# RUN echo '#!/bin/bash\n\
# source /opt/conda/etc/profile.d/conda.sh\n\
# ENV_NAME=$(grep "name:" environment.yml | cut -d" " -f2)\n\
# conda activate $ENV_NAME\n\
# exec "$@"' > /entrypoint.sh && \
#     chmod +x /entrypoint.sh

# #!/bin/bash
# # Activate Conda environment
# source /opt/conda/etc/profile.d/conda.sh
# conda activate ai-imu

# # Execute any command passed to the container
# exec "$@"
# # Set the entrypoint
# ENTRYPOINT ["/entrypoint.sh"]

# # Set the default command to bash
# CMD ["/bin/bash"]

# Generate the script during the build
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'source /opt/conda/etc/profile.d/conda.sh' >> /entrypoint.sh && \
    echo 'conda activate ai-imu' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the script as the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]