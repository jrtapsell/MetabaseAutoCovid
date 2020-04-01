FROM alpine

RUN mkdir /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown appuser:appgroup /app

USER appuser
WORKDIR /app
RUN wget -O ./metabase.jar https://downloads.metabase.com/latest/metabase.jar

USER root
RUN apk add openjdk8-jre python3 bash postgresql nginx
USER appuser

ADD ./python/requirements.txt ./python/requirements.txt
USER root
RUN pip3 install -r ./python/requirements.txt
USER appuser

USER root
RUN mkdir -p /var/lib/nginx/logs/ && chown -R appuser:appgroup /var/lib/nginx/
RUN ln -s /dev/shm/fake_tmp/nginx_run /run/nginx
RUN ln -s /dev/shm/fake_tmp/postgresql /run/
USER appuser

ADD ./python/* ./python/
ADD ./postgres/* ./postgres/

ADD ./entrypoint.sh ./

ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /var/lib/nginx/tmp && ln -s /tmp/nginx_tmp /var/lib/nginx/tmp
VOLUME tmp

RUN ln -s /dev/shm/fake_tmp/data /tmp

CMD ["/app/entrypoint.sh"]