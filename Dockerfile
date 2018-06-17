# Pull base image.
FROM frolvlad/alpine-oraclejdk8:latest

# Define versions and environment
ENV DOCKER_CHANNEL edge
ENV DOCKER_VERSION 18.05.0-ce
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

ENV MAVEN_VERSION=3.5.3 
ENV NPM_VERSION=8.11.3
ENV YARN_VERSION=1.7.0

ENV M2_HOME="/opt/apache-maven-${MAVEN_VERSION}"
ENV NODE_HOME="/opt/node-v${NPM_VERSION}-linux-x64"
ENV YARN_HOME="/opt/yarn-v${YARN_VERSION}"

ENV PATH="$PATH:${JAVA_HOME}/bin:${M2_HOME}/bin:${NODE_HOME}/bin:${YARN_HOME}/bin"

ENV LD_LIBRARY_PATH="/usr/glibc-compat/lib/libc.so.6"

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
RUN apk add --no-cache ca-certificates
RUN apk add --no-cache bash
RUN apk add --no-cache curl
RUN apk add --no-cache tar
RUN apk add --no-cache libstdc++
RUN apk add --no-cache fontconfig

RUN apk add --no-cache git


# Install docker-in-docker

# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/docker/docker-ce/blob/v17.09.0-ce/components/engine/hack/make.sh#L149
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN echo 'hosts: files dns mdns4_minimal mdns4' > /etc/nsswitch.conf



RUN set -ex; \
# why we use "curl" instead of "wget":
# + wget -O docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-17.03.1-ce.tgz
# Connecting to download.docker.com (54.230.87.253:443)
# wget: error getting response: Connection reset by peer
	
# this "case" statement is generated via "update.sh"
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64) dockerArch='x86_64' ;; \
		armhf) dockerArch='armel' ;; \
		aarch64) dockerArch='aarch64' ;; \
		ppc64le) dockerArch='ppc64le' ;; \
		s390x) dockerArch='s390x' ;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
	esac; \
	\
	if ! curl -fL -o docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd -v; \
	docker -v

COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/


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

ENTRYPOINT ["docker-entrypoint.sh"]

# Define default command.
CMD ["bash"]