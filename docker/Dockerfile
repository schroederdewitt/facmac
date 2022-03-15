FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
MAINTAINER ANONYMOUS

# CUDA includes
ENV CUDA_PATH /usr/local/cuda
ENV CUDA_INCLUDE_PATH /usr/local/cuda/include
ENV CUDA_LIBRARY_PATH /usr/local/cuda/lib64

# Ubuntu Packages
RUN apt-get update -y && apt-get install software-properties-common -y && \
    add-apt-repository -y multiverse && apt-get update -y && apt-get upgrade -y && \
    apt-get install -y apt-utils nano vim man build-essential wget sudo && \
    rm -rf /var/lib/apt/lists/*

# Install curl and other dependencies
RUN apt-get update -y && apt-get install -y curl libssl-dev openssl libopenblas-dev \
    libhdf5-dev hdf5-helpers hdf5-tools libhdf5-serial-dev libprotobuf-dev protobuf-compiler git

# Create local user
# https://jtreminio.com/blog/running-docker-containers-as-current-host-user/
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} duser
RUN useradd -l -u ${USER_ID} -g duser duser
RUN install -d -m 0755 -o duser -g duser /home/duser
RUN chown --changes --silent --no-dereference --recursive ${USER_ID}:${GROUP_ID} /home/duser
 
#Install python3 pip3
RUN apt-get update
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && apt-get install -y python3.8 python3.8-dev
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2
RUN apt-get install -y python3-pip
RUN apt-get install -y python-apt --reinstall
RUN apt-get install -y htop iotop
RUN python3 -m pip uninstall pip setuptools wheel
RUN apt-get --reinstall install  python3-setuptools python3-wheel python3-pip
RUN apt-get install -y python3.8-venv

# Other system level tools
RUN apt-get install -y htop iotop

# Mujoco I
RUN apt install -y libosmesa6-dev libgl1-mesa-glx libglfw3
RUN ln -s /usr/lib/x86_64-linux-gnu/libGL.so.1 /usr/lib/x86_64-linux-gnu/libGL.so
RUN apt install -y unzip patchelf

####### USER AREA ##########################################
USER duser
WORKDIR /home/duser
RUN mkdir ~/install

# Virtual Env
ENV VIRTUAL_ENV=~/venv
RUN python3 -m venv venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN ~/venv/bin/python3 -m pip install --upgrade pip

# Install dependencies:
# COPY requirements.txt .
# RUN pip install -r requirements.txt

# install Sacred
RUN . /home/duser/venv/bin/activate && pip3 install jsonpickle==0.9.6 setuptools
RUN git clone https://github.com/oxwhirl/sacred.git /home/duser/install/sacred
RUN cd /home/duser/install/sacred && . /home/duser/venv/bin/activate && python3 setup.py install

# Install pymongo
RUN . /home/duser/venv/bin/activate && pip3 install pymongo torch torchvision snakeviz pytest probscale Jinja2 Cython numpy scipy pyyaml matplotlib tensorboard-logger imageio

#### -------------------------------------------------------------------
#### install mujoco
#### -------------------------------------------------------------------
RUN . /home/duser/venv/bin/activate && yes | pip3 uninstall enum34

# Make sure you have a license key, otherwise comment it out
RUN mkdir /home/duser/.mujoco
COPY ./mjkey.txt /home/duser/.mujoco/mjkey.txt

# RUN mkdir -p /home/duser/.mujoco \
#    && wget https://www.roboti.us/download/mujoco200_linux.zip -O /home/duser/mujoco.zip \
#    && unzip /home/duser/mujoco.zip -d /home/duser/.mujoco \
#    && rm /home/duser/mujoco.zip \
#    && mv /home/duser/.mujoco/mujoco200_linux /home/duser/.mujoco/mujoco200

RUN mkdir -p ~/.mujoco \
    && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O /home/duser/mujoco.tar.gz \
    && tar -xvzf /home/duser/mujoco.tar.gz \
    && cp -r /home/duser/mujoco210 /home/duser/.mujoco \
    && rm /home/duser/mujoco.tar.gz 
    
ENV LD_LIBRARY_PATH /home/duser/.mujoco/mujoco200/bin:${LD_LIBRARY_PATH}
ENV MUJOCO_PY_MJKEY_PATH /home/duser/.mujoco/mjkey.txt
ENV MUJOCO_PY_MUJOCO_PATH /home/duser/.mujoco/mujoco210

RUN . /home/duser/venv/bin/activate && MUJOCO_PY_MUJOCO_PATH=/home/duser/.mujoco/mujoco210 pip3 install mujoco-py
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/duser/.mujoco/mujoco210/bin" >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/duser/.mujoco/mujoco210/bin" >> ~/.profile
RUN . /home/duser/venv/bin/activate && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/duser/.mujoco/mujoco210/bin && \
    export MUJOCO_PY_MUJOCO_PATH=/home/duser/.mujoco/mujoco210 && python3 -c "import mujoco_py"

# set python path
RUN echo "export PYTHONPATH=~/entryfolder" >> /home/duser/.bashrc
RUN echo "export PYTHONPATH=~/entryfolder" >> /home/duser/.profile

RUN . ~/venv/bin/activate && pip3 install gym==0.10.8

## -- SMAC --
# Change the smac_ver to make sure the newest smac is installed when rebuilding the docker image
ENV smac_ver 1
RUN . /home/duser/venv/bin/activate && pip3 install git+https://github.com/oxwhirl/smac.git
ENV SC2PATH ~/entryfolder/3rdparty/StarCraftII

# make sure virtualenv is activated by default
RUN echo "source ~/venv/bin/activate" >> ~/.bashrc
RUN echo "source ~/venv/bin/activate" >> ~/.profile

EXPOSE 8888
WORKDIR /home/duser/entryfolder
