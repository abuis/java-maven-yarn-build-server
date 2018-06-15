# Pull base image.
FROM frolvlad/alpine-oraclejdk8:latest

# Define versions and environment
ENV MAVEN_VERSION=3.5.3 
ENV NPM_VERSION=8.11.3
ENV YARN_VERSION=1.7.0

ENV M2_HOME="/opt/apache-maven-${MAVEN_VERSION}"
ENV NODE_HOME="/opt/node-v${NPM_VERSION}-linux-x64"
ENV YARN_HOME="/opt/yarn-v${YARN_VERSION}"

ENV PATH="$PATH:${JAVA_HOME}/bin:${M2_HOME}/bin:${NODE_HOME}/bin:${YARN_HOME}/bin"

# Install Yarn package repository
#RUN apt-get update && apt-get install -y apt-transport-https ca-certificates apt-utils
#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
#RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install time and ts to get timing information
#RUN apt-get update && apt-get install -y time moreutils python-pip

#RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
#RUN apt-cache showpkg nodejs

# 6.9.2 is not available, so using 6.9.4 instead.
#RUN apt-get install -y nodejs=6.9.4-1nodesource1~jessie1

# Install Yarn
#RUN apt-get install -y yarn=0.17.10-1

#RUN pip install boto3 # required for s3_upload.py

# Install base utilities
RUN apk add --no-cache bash
RUN apk add --no-cache curl
RUN apk add --no-cache libstdc++

# Create /opt directory
RUN mkdir /opt

# Install Maven
RUN cd /opt && curl -o- http://apache.mirror.serversaustralia.com.au/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar xz

# Copy maven repository across
#ADD repository/ /root/.m2/repository/

# Install NodeJS
RUN cd /opt && curl -o- https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-x64.tar.gz | tar xz

# Install Yarn 
RUN cd /opt && curl -L -o- https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz | tar xz

# Create bashrc
RUN mkdir /root/.m2 && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> /root/.bashrc && \
    echo "export M2_HOME=/opt/apache-maven-${MAVEN_VERSION}" >> /root/.bashrc && \
    echo "export NODE_HOME=/opt/node-v${NPM_VERSION}-linux-x64" >> /root/.bashrc && \
    echo "export YARN_HOME=/opt/yarn-v${YARN_VERSION}" >> /root/.bashrc && \
    echo "export PATH=$PATH" >> /root/.bashrc


# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]