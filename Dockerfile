FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris
ENV HOME=/root
ENV XDG_CONFIG_HOME=/root/.config
ENV PATH=$PATH:/root/.local/bin

# --- System dependencies ---
RUN apt-get update && apt-get install -y \
    git curl wget build-essential gcc g++ make cmake unzip gettext nano ripgrep fd-find nodejs python3-pip \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js (latest LTS) ---
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && npm install -g npm

# --- Neovim (latest stable) ---
RUN curl -L -o /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz && \
    mv /opt/nvim-linux-x86_64 /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim && \
    rm /tmp/nvim-linux-x86_64.tar.gz

# --- Python deps ---
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt

# --- Copy configs ---
COPY ./nvim-config /root/.config/nvim

# --- Create runtime folders for VSCode/Jupyter ---
RUN mkdir -p /root/.local/share/jupyter /root/.vscode-server /root/.venvs

WORKDIR /root/work
COPY . /root/work

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token="]
