# client port (2188/tcp), peer connection port (2888/tcp), leader election port (3888/tcp)
# server.<myid>=<hostname>:<leaderport>:<electionport>
version: '3.7'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper
    restart: always
    network_mode: host
    container_name: zookeeper
    environment:
      ZOOKEEPER_SERVER_ID: ${zk_server_id}
      ZOOKEEPER_CLIENT_PORT: ${zk_server_port}
      ZOOKEEPER_SERVERS: "${zk_servers}"
      KAFKA_OPTS:
        -Djava.security.auth.login.config=/etc/zk/secrets/jaas_zk.conf
        -Dzookeeper.authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
        -DrequireClientAuthScheme=sasl
        -Dquorum.auth.enableSasl=true
        -Dquorum.auth.learnerRequireSasl=true
        -Dquorum.auth.serverRequireSasl=true
        -Dquorum.auth.learner.loginContext=QuorumLearner
        -Dquorum.auth.server.loginContext=QuorumServer
        -Dquorum.cnxn.threads.size=20
      KAFKA_JMX_PORT: ${zk_jmx_port}
      KAFKA_JMX_HOSTNAME: zookeeper${zk_server_id}
      KAFKA_JMX_OPTS: '-Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false'
    volumes:
      - /tmp/zk:/etc/zk/secrets
    ports:
      - ${zk_server_port}:${zk_server_port}
      - 2888
      - 3888