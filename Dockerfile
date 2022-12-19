FROM jenkins/jenkins:lts as jenkins

USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin

ARG CERT_DIR=/certs

ARG CA_FILE=ca.cert.pem
ARG PK_FILE=pk.key.pem

ARG P12_FILE=keystore.p12
ARG JKS_FILE=keystore.jks

ARG CERT_PASS=prdxone

RUN mkdir -p $CERT_DIR
RUN cd $CERT_DIR

ADD $CA_FILE $CERT_DIR
ADD $PK_FILE $CERT_DIR

RUN openssl pkcs12 \
      -export \
      -out $CERT_DIR/$P12_FILE \
      -passout "pass:$CERT_PASS" \
      -inkey $CERT_DIR/$PK_FILE \
      -in $CERT_DIR/$CA_FILE \
      -name prdx

RUN keytool \
      -importkeystore \
      -srckeystore $CERT_DIR/$P12_FILE \
      -srcstorepass "$CERT_PASS" \
      -srcstoretype PKCS12 \
      -srcalias prdx \
      -deststoretype JKS \
      -destkeystore $CERT_DIR/$JKS_FILE \
      -deststorepass "$CERT_PASS" \
      -destalias prdx

USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow publish-over-ssh"

ENV JENKINS_OPTS --httpPort=-1 --httpsPort=443 --httpsKeyStore=$CERT_DIR/$JKS_FILE --httpsKeyStorePassword=$CERT_PASS
