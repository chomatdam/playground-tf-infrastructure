#!/bin/sh

# exit when any command fails
#set -e

# start cluster
docker-compose up -d

# Wait for Kafka brokers to be reachable
NB_BROKERS_EXPECTED=1
TIMEOUT=10
docker-compose exec kafka1 cub kafka-ready ${NB_BROKERS_EXPECTED} ${TIMEOUT} -z "zookeeper:2181" -s INTERNAL -c /etc/kafka/secrets/consumer.properties


# Arguments (shift used to rotate arguments)
while [[ ! $# -eq 0 ]]
do
	case "$1" in
	    --help | -h)
	        echo "--init-topics | -t     create topics you defined in your run.sh"
	        echo "--create-users | -u    encrypt and save to zookeeper credentials you defined in your run.sh"
	        exit 1;
	        ;;
	    --init-topics)
	        create_topics
	        ;;
		--create-users)
			encrypt_and_save_user_passwords
			;;
        --upload-s3-connect-cfg)
			upload_s3_kafka_connect_config
			;;
	esac
	shift
done

# Functions
encrypt_and_save_user_passwords () {
    USERS=( broker client restproxy schemaregistry connect)
    PASSWORDS=( broker-secret client-secret restproxy-secret schemaregistry-secret connect-secret )
    for index in ${!USERS[*]}; do
        docker-compose exec kafka1 kafka-configs --zookeeper zookeeper:2181 --alter --entity-type users --entity-name ${USERS[$index]} --add-config "SCRAM-SHA-512=[password=${PASSWORDS[$index]}]"
    done
}

create_topics () {
    TOPICS=( topic1 topic2)
    for index in ${!USERS[*]}; do
        docker-compose exec kafka1 kafka-topics --zookeeper zookeeper:2181 --create --topic ${USERS[$index]} --partitions 1 --replication-factor 1
    done
}

upload_s3_kafka_connect_config () {
#(cd connectors && curl -X GET -L https://github.com/confluentinc/kafka-connect-storage-cloud/archive/v5.2.1.zip -o kafka-s3-connector.zip)
docker-compose exec kafka-connect curl -X POST \
                                       -H "Content-Type: application/json" \
                                       --data @/etc/kafka/connectors/s3-sink.json \
                                       --cert /etc/kafka/secrets/connect.certificate.pem \
                                       --key /etc/kafka/secrets/connect.key \
                                       --tlsv1.2 \
                                       --cacert /etc/kafka/secrets/snakeoil-ca-1.crt \
                                       http://kafka-connect:8083/connectors
}
