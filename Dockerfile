FROM alpine

RUN mkdir /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown appuser:appgroup /app

USER appuser
WORKDIR /app
RUN wget -O ./metabase.jar https://downloads.metabase.com/latest/metabase.jar

USER root
RUN apk add openjdk8 python3 bash postgresql nginx jq curl postgresql-dev gcc python3-dev musl-dev openssl
USER appuser

ADD ./python/requirements.txt ./python/requirements.txt
USER root
RUN pip3 install -r ./python/requirements.txt
USER appuser

USER root
RUN mkdir -p /var/lib/nginx/logs/ && chown -R appuser:appgroup /var/lib/nginx/
RUN mkdir /tmp/postgresql && ln -s /tmp/postgresql /run/ && chown appuser:appgroup /tmp/postgresql
RUN rm -rf /var/lib/nginx/tmp && ln -s /tmp/nginx_tmp /var/lib/nginx/tmp
RUN mkdir -p /tmp/nginx_run/nginx && ln -s /tmp/nginx_run/nginx /run/ && chown appuser:appgroup /tmp/nginx_run/nginx
USER appuser

ADD ./python/* ./python/
ADD ./postgres/* ./postgres/

ADD ./entrypoint.sh ./

ADD ./nginx/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["sleep infinity"]