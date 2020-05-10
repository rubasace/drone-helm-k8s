FROM alpine/helm

ENV KUBECONFIG /.kube/config

RUN apk add --update --no-cache gettext

COPY kube_config /.kube

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

