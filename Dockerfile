FROM python:3.9.12-bullseye

ARG DEBIAN_FRONTEND="noninteractive"

ENV PIP_NO_CACHE_DIR="off"
ENV PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "


# libeccodes-dev is necessary to `pygrib` on prod environment.
# libgeos-dev and libgdal-dev are necessary to `Cartopy` on dev environment.
# TODO: separate environment into dev and prod.
RUN apt-get update \
    && apt-get install -y git libeccodes-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# libgeos-dev and libgdal-dev are necessary to `Cartopy` on dev environment.
# git-lfs is used on dev environment.
RUN apt-get update \
    && apt-get install -y libgeos-dev libgdal-dev vim\
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -U pip

ARG GIT_ACCESS_TOKEN
RUN git config --global url."https://${GIT_ACCESS_TOKEN}@github.com".insteadOf "ssh://git@github.com"

WORKDIR /chaos_hm
COPY  pyproject.toml /chaos_hm/

RUN pip install dulwich==0.21.2 poetry==1.4.0
RUN poetry config virtualenvs.create false\
    && poetry install 

RUN echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /root/.bashrc
RUN echo 'alias ls="ls -a --color=auto"' >> /root/.bashrc
RUN . /root/.bashrc