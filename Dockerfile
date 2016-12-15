# Pull base image.
FROM openjdk:8-jdk

# Install time and ts to get timing information
RUN apt-get update && apt-get install -y time moreutils python-pip

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install nodejs
RUN npm install -g yarn

RUN pip install boto3 # required for s3_upload.py

RUN cd /opt && curl -o- http://apache.mirror.serversaustralia.com.au/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz
RUN mkdir /root/.m2 && \
    echo "export M2_HOME=/opt/apache-maven-3.3.9" >> /root/.bashrc && \
    echo "export PATH=$PATH:/opt/apache-maven-3.3.9/bin" >> /root/.bashrc

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]