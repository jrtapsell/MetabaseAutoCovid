FROM alpine:3.11.5

RUN mkdir /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown appuser:appgroup /app

USER appuser
WORKDIR /app
RUN wget -O ./metabase.jar https://downloads.metabase.com/v0.35.1/metabase.jar

USER root
RUN apk add \
    openjdk8=8.242.08-r0 \
    python3=3.8.2-r0 \
    bash=5.0.11-r1 \
    postgresql=12.2-r0 \
    nginx=1.16.1-r6 \
    jq=1.6-r0 \
    curl=7.67.0-r0 \
    postgresql-dev=12.2-r0 \
    gcc=9.2.0-r4 \
    python3-dev=3.8.2-r0 \
    musl-dev=1.1.24-r2 \
    openssl=1.1.1d-r3 \
    fontconfig=2.13.1-r2 \
    ttf-dejavu=2.37-r1 \
    --no-cache && rm -rf /var/cache/apk/*
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
ADD ./countries_ammendments.csv ./

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["sleep infinity"]