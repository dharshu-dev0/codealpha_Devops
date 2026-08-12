FROM jenkins/jenkins:lts-jdk17

# Skip the setup wizard (also set via JAVA_OPTS in docker-compose.yml,
# but harmless to set it here too as a fallback).
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Install the plugins needed for SSH remoting + Configuration-as-Code + pipelines
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Bake in the JCasC config that defines the two remote SSH agent nodes
# and the SSH credential used to reach them.
COPY casc/jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins.yaml
