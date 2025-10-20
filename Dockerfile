# FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime                                   
                                                                                       
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive         
ENV TZ=Europe/Paris                        
                                                                                       
                                           
                                           
                                           
# Copy nvim config                         
#COPY ~/.config/nvim /root/.config/nvim                                                                                                                                       
# COPY ~/.local/share/nvim /root/.local/share/nvim                                     







# Install system dependencies              
RUN apt-get update && apt-get install -y \ 
    git \                                  
    curl \                                 
    wget \                                 
    build-essential \                      
    gcc \                                  
    g++ \                                  
    make \                                 
    cmake \                                
    unzip \                                
    gettext \                              
    nano \                                 
    ripgrep \                              
    fd-find \                              
        nodejs \                                 
    python3-pip \                          
    && rm -rf /var/lib/apt/lists/*         


# Install Node.js and npm (latest LTS)     
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# create a non-root user
ARG USERNAME=dev
ARG UID=1000
RUN useradd -m -u ${UID} ${USERNAME}

# install latest stable Neovim (from GitHub releases)
# you could change to nightly by switching URL/tag
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && mv /opt/nvim-linux-x86_64 /opt/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && rm nvim-linux-x86_64.tar.gz

RUN echo "alias ll='ls -la'" >> /home/${USERNAME}/.bashrc
RUN echo "alias v='nvim'" >> /home/${USERNAME}/.bashrc
RUN git config --global --add safe.directory /home/${USERNAME}/work/'*'
COPY requirements.txt /tmp/requirements.txt  
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements.txt  
# Optional: folder for project virtualenvs
RUN mkdir -p /home/${USERNAME}/.venvs

# optionally: copy your config. You can also mount config at runtime instead.
COPY --chown=${USERNAME} ./nvim-config  /home/${USERNAME}/.config/nvim

# environment for XDG etc if needed
ENV XDG_CONFIG_HOME=/home/${USERNAME}/.config
ENV HOME=/home/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}


COPY . /home/dev/work                      
                      

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--NotebookApp.token="]
