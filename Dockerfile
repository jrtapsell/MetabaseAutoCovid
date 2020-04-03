FROM alpine:3.11.5

RUN mkdir /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown appuser:appgroup /app

USER appuser
WORKDIR /app
RUN wget -O ./metabase.jar https://downloads.metabase.com/v0.34.3/metabase.jar

USER root
RUN apk add \
    openjdk8=8.242.08-r1 \
    python3=3.8.2-r1 \
    bash=5.0.16-r0 \
    postgresql=12.2-r3 \
    nginx=1.16.1-r8 \
    jq=1.6-r1 \
    curl=7.69.1-r0 \
    postgresql-dev=12.2-r3 \
    gcc=9.3.0-r1 \
    python3-dev=3.8.2-r1 \
    musl-dev=1.1.24-r5 \
    openssl=1.1.1f-r0 --no-cache && rm -rf /var/cache/apk/*
USER appuser

COPY ./python/requirements.txt ./python/requirements.txt
USER root
RUN pip3 install -r ./python/requirements.txt
USER appuser

USER root
RUN mkdir -p /var/lib/nginx/logs/ && chown -R appuser:appgroup /var/lib/nginx/
RUN mkdir /tmp/postgresql && ln -s /tmp/postgresql /run/ && chown appuser:appgroup /tmp/postgresql
RUN rm -rf /var/lib/nginx/tmp && ln -s /tmp/nginx_tmp /var/lib/nginx/tmp
RUN mkdir -p /tmp/nginx_run/nginx && ln -s /tmp/nginx_run/nginx /run/ && chown appuser:appgroup /tmp/nginx_run/nginx
USER appuser

COPY ./python/* ./python/
COPY ./postgres/* ./postgres/

COPY ./entrypoint.sh ./

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["sleep infinity"]