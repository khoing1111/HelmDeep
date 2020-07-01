FROM alpine/helm:3.2.4

# Setup workplace and helm environment
ENV BIN_HOME=/home/app/bin
ENV PATH=${PATH}:${BIN_HOME}
ENV CHARTS_HOME=/home/app/charts
ENV REPO_HOME=/home/app/repo

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install Gloud SDK
## To solve prompt issue within container (requires ncurses)
ENV COLUMNS="`tput cols`"
ENV LINES="`tput lines`"

## Google cloud SDK require python
RUN apk --update add vim python3 ncurses python3-dev py3-pip

## Install google cloud SDK and it's components
WORKDIR /home
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-271.0.0-linux-x86_64.tar.gz
RUN tar -xf google-cloud-sdk-271.0.0-linux-x86_64.tar.gz
RUN rm google-cloud-sdk-271.0.0-linux-x86_64.tar.gz
RUN /bin/sh -c google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=$HOME/.bashrc
ENV PATH=${PATH}:/home/google-cloud-sdk/bin
RUN gcloud components install kubectl alpha beta

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install bash completetion and python requirements
WORKDIR /home/app
COPY requirements.txt /home/app
RUN pip3 install -r /home/app/requirements.txt

# Add git so that we can use diff to compare changes
RUN apk add git curl

# Install  bash completion
RUN apk add bash bash-doc bash-completion

# Update bash command color and autocomplete into startup bash script
COPY bash-init /home/app
RUN cat /home/app/bash-init >> $HOME/.bashrc
