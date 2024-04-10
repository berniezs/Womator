# Generated by Neurodocker version 0.4.3-2-g01cdd22
# Timestamp: 2019-01-16 17:35:01 UTC
#
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
#
#     https://github.com/kaczmarj/neurodocker

FROM neurodebian:stretch-non-free

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
           git \
           make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           gcc \
           g++ \
           software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

COPY [".", "/src/NiMARE/"]

ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"
RUN export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && sync && conda clean -tipsy && sync \
    && conda create -y -q --name nimare \
    && conda install -y -q --name nimare \
           'python=3.6' \
           'jupyter' \
           'jupyterlab' \
           'jupyter_contrib_nbextensions' \
           'pytest' \
           'pytest-cov' \
           'codecov' \
    && sync && conda clean -tipsy && sync \
    && bash -c "source activate nimare \
    &&   pip install --no-cache-dir  \
             '/src/NiMARE/'" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate nimare' $ND_ENTRYPOINT

RUN mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py

USER root

RUN apt-get update && add-apt-repository -y ppa:openjdk-r/ppa && apt-get install -y --no-install-recommends openjdk-8-jdk openjdk-8-jre

RUN update-alternatives --config java && update-alternatives --config javac

RUN curl -o mallet-2.0.7.tar.gz http://mallet.cs.umass.edu/dist/mallet-2.0.7.tar.gz && tar xzf mallet-2.0.7.tar.gz && rm mallet-2.0.7.tar.gz && mkdir /home/neuro/.nimare && mv mallet-2.0.7 /home/neuro/.nimare/mallet

WORKDIR /home/neuro

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "neurodebian:stretch-non-free" \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "gcc", \
    \n        "g++", \
    \n        "software-properties-common" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        ".", \
    \n        "/src/NiMARE/" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "create_env": "nimare", \
    \n        "miniconda_version": "4.3.31", \
    \n        "conda_install": [ \
    \n          "python=3.6", \
    \n          "jupyter", \
    \n          "jupyterlab", \
    \n          "jupyter_contrib_nbextensions" \
    \n        ], \
    \n        "pip_install": [ \
    \n          "/src/NiMARE/" \
    \n        ], \
    \n        "activate": true \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \\\"0.0.0.0\\\" > ~/.jupyter/jupyter_notebook_config.py" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "root" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "apt-get update && add-apt-repository -y ppa:openjdk-r/ppa && apt-get install -y --no-install-recommends openjdk-8-jdk openjdk-8-jre" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "update-alternatives --config java && update-alternatives --config javac" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "curl -o mallet-2.0.7.tar.gz http://mallet.cs.umass.edu/dist/mallet-2.0.7.tar.gz && tar xzf mallet-2.0.7.tar.gz && rm mallet-2.0.7.tar.gz && mkdir /home/neuro/resources && mv mallet-2.0.7 /home/neuro/resources/mallet" \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/home/neuro" \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json