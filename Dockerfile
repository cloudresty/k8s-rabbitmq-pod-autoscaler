#   ____ _                 _               _         
#  / ___| | ___  _   _  __| |_ __ ___  ___| |_ _   _ 
# | |   | |/ _ \| | | |/ _` | '__/ _ \/ __| __| | | |
# | |___| | (_) | |_| | (_| | | |  __/\__ \ |_| |_| |
#  \____|_|\___/ \__,_|\__,_|_|  \___||___/\__|\__, |
#                                              |___/ 
#
#  Dockerfile for RabbitMQ queue length check based on Alpine Linux
#
#  https://github.com/cloudresty/k8s-rabbitmq-pod-autoscaler
#

            # Base image
FROM        alpine:3.11

            # Needed packages
RUN         apk add --update --no-cache \
                curl \
                bash \
                jq \
                bc

            # Get latest kubectl available
RUN         cd /usr/local/bin && \
            curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
            chmod 755 /usr/local/bin/kubectl

            # Copy autoscale.sh shell script
COPY        src/autoscale.sh /bin/autoscale.sh

            # Make shell executable
RUN         chmod +x /bin/autoscale.sh

            # RabbitMQ queue check interval
ENV         INTERVAL 30

            # Log verbosity
ENV         LOGS HIGH

            # Container command
CMD         ["bash", "/bin/autoscale.sh"]