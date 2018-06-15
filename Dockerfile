# Pull base image.
FROM frolvlad/alpine-oraclejdk8:latest

ENV MAVEN_VERSION=3.5.3 

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

RUN cd /opt && curl -o- http://apache.mirror.serversaustralia.com.au/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz
RUN cd /opt && curl -o- http://apache.mirror.serversaustralia.com.au/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar xz
RUN mkdir /root/.m2 && \
    echo "export M2_HOME=/opt/apache-maven-${MAVEN_VERSION}" >> /root/.bashrc && \
    echo "export PATH=$PATH:/opt/apache-maven-${MAVEN_VERSION}/bin" >> /root/.bashrc

# Copy maven repository across
#ADD repository/ /root/.m2/repository/

# Install Yarn 
RUN apk add yarn

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]