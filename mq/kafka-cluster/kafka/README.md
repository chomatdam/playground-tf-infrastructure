### Kafka
#### Test your SSL certificate
```
openssl s_client -connect localhost:9094 -tls1
```

#### Produce messages
```
kafka-console-producer --broker-list kafka1:9094 --producer.config /etc/kafka/consumer.properties --topic test
```

#### Receives messages
```
kafka-console-consumer --bootstrap-server kafka1:9094 --consumer.config /etc/kafka/consumer.properties --topic test --from-beginning
```
#### Show consumers
```
kafka-consumer-groups --bootstrap-server kafka1:9092 --list --command-config /Users/chomatdam/go/src/awesomeProject/infra/tests/consumer.properties
```
#### superDigest Zookeeper
```
PASSWORD=$(echo -n "super:super-secret" | openssl sha1 -binary | base64)
-Dzookeeper.DigestAuthenticationProvider.superDigest=super:$PASSWORD
```
