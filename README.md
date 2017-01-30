# java-maven-yarn-build-server

To test for a BitBucket pipelines build locally:

sudo docker run -it --volume=/source-code-location:/localDebugRepo --workdir="/localDebugRepo" --memory=4g --memory-swap=4g --entrypoint=/bin/bash java-maven-yarn-build-server