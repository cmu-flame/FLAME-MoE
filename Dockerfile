FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

# Update package lists and install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    clang-format \
    clangd-14 \
    python3 \
    python-is-python3 \
    python3-venv \
    vim \
    zsh \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Configure zsh
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="fino-time"/' ~/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' ~/.zshrc

# Create a non-root user
ARG USERNAME=moe
ARG USER_UID=1003
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Copy zsh configuration to the new user's home
RUN cp -r /root/.oh-my-zsh /home/$USERNAME/.oh-my-zsh && \
    cp /root/.zshrc /home/$USERNAME/.zshrc && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.oh-my-zsh && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.zshrc

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Install python
COPY install/install_python.sh /install/install_python.sh
RUN bash /install/install_python.sh py310

# clangd
ENV PATH="/usr/lib/llvm-14/bin:$PATH"
# conda
ENV PATH="/home/moe/conda/bin:$PATH"
ENV PATH="/home/moe/conda/envs/py310/bin:$PATH"

# Install python packages
COPY install/install_python_packages.sh /install/install_python_packages.sh
COPY install/requirements.txt requirements.txt
RUN bash /install/install_python_packages.sh

# COPY install/install_apex.sh /install/install_apex.sh
# COPY --chown=moe:moe apex/ apex/
# RUN bash /install/install_apex.sh

COPY install/install_lm_evaluation_harness.sh /install/install_lm_evaluation_harness.sh
COPY --chown=moe:moe lm-evaluation-harness/ lm-evaluation-harness/
RUN bash /install/install_lm_evaluation_harness.sh

# COPY install/install_transformer_engine.sh /install/install_transformer_engine.sh
# COPY --chown=moe:moe TransformerEngine/ TransformerEngine/
# RUN bash /install/install_transformer_engine.sh

RUN echo "source activate py310" >> /home/moe/.zshrc

# Install aws-cli
COPY install/install_aws_cli.sh /install/install_aws_cli.sh
RUN bash /install/install_aws_cli.sh

# Set zsh as default shell
ENV SHELL=/bin/zsh
CMD [ "zsh" ]