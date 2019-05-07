QuorumServer {
    org.apache.zookeeper.server.auth.DigestLoginModule required
    user_zookeeper="${zookeeper_password}";
};
QuorumLearner {
    org.apache.zookeeper.server.auth.DigestLoginModule required
    username="zookeeper"
    password="${zookeeper_password}";
};
Server {
    org.apache.zookeeper.server.auth.DigestLoginModule required
    user_super="${super_password}"
    user_kafka="${kafka_password}";
};
