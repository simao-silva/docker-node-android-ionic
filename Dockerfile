FROM ubuntu:20.04

LABEL maintainer="joaopopedrosa@gmail.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="docker-node-android-ionic" \
      org.label-schema.description="Image base on Ubuntu 20.04." \
      org.label-schema.vendor="João Pedro Pedrosa" \
      org.label-schema.url="https://github.com/joaoppedrosa/docker-node-android-ionic" \
      org.label-schema.usage="https://github.com/joaoppedrosa/docker-node-android-ionic/blob/master/README.md" \
      org.label-schema.vcs-url="https://github.com/joaoppedrosa/docker-node-android-ionic.git" \
      org.label-schema.license="MIT" \
      org.opencontainers.image.title="docker-node-android-ionic" \
      org.opencontainers.image.description="Image base on Ubuntu 20.04." \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="João Pedro Pedrosa" \
      org.opencontainers.image.vendor="João Pedro Pedrosa" \
      org.opencontainers.image.url="https://github.com/joaoppedrosa/docker-node-android-ionic" \
      org.opencontainers.image.documentation="https://github.com/joaoppedrosa/docker-node-android-ionic/blob/master/README.md" \
      org.opencontainers.image.source="https://github.com/joaoppedrosa/docker-node-android-ionic.git"

ENV DEBIAN_FRONTEND=noninteractive \
      TERM=xterm

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Install Java
RUN apt-get update && \
    apt-get -y install openjdk-8-jdk-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    java -version

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install Git
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git
    
# Install Ruby
RUN \
  apt-get update && apt-get install -y --no-install-recommends --no-install-suggests curl bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* && \
  curl -L https://github.com/sstephenson/ruby-build/archive/v20180329.tar.gz | tar -zxvf - -C /tmp/ && \
  cd /tmp/ruby-build-* && ./install.sh && cd / && \
  ruby-build -v 2.5.1 /usr/local && rm -rfv /tmp/ruby-build-* && \
  gem install bundler --no-rdoc --no-ri && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
# Install Python
RUN apt update -y && apt upgrade -y && \
    apt-get install -y wget build-essential checkinstall  libreadline-gplv2-dev  libncursesw5-dev  libssl-dev  libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && \
    cd /usr/src && \
    wget https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz | tar -zxvf - -C /tmp/ && \
    cd /tmp/Python-2.7.12 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android (https://developer.android.com/studio/#downloads)
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip" \
    ANDROID_BUILD_TOOLS_VERSION=32.0.0 \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_SDK_ROOT="/opt/android" \
    ANDROID_HOME="/opt/android/android-sdk-linux"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

RUN apt-get -qq update && \
    apt-get -qq install -y wget curl maven ant gradle

# Installs Android SDK
RUN mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip

RUN mkdir /root/.android && touch /root/.android/repositories.cfg && \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-32" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" &&  \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "add-ons;addon-google_apis-google-24" "skiaparser;1"

RUN chmod a+x -R $ANDROID_SDK_ROOT && \
    chown -R root:root $ANDROID_SDK_ROOT && \
    rm -rf /opt/android/licenses && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean && \
    mvn -v && gradle -v && java -version && ant -version

# Installs Node
ENV NODE_VERSION=8.9.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version


# Installs Ionic and Cordova
ENV IONIC_VERSION=2.2.0
ENV CORDOVA_VERSION=8.1.1
RUN npm install -g --unsafe-perm ionic@${IONIC_VERSION} && \
    ionic --version && \
    npm install -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    cordova --version && \
    npm install -g yarn && \
    yarn -v && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
