FROM alpine

RUN mkdir /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown appuser:appgroup /app

USER appuser
WORKDIR /app
RUN wget -O ./metabase.jar https://downloads.metabase.com/latest/metabase.jar

USER root
RUN apk add openjdk8-jre python3 bash postgresql
USER appuser

ADD ./python/requirements.txt ./python/requirements.txt
USER root
RUN pip3 install -r ./python/requirements.txt
USER appuser

USER root
RUN mkdir /run/postgresql/ && chown appuser:appgroup /run/postgresql/
USER appuser

ADD ./python/* ./python/
ADD ./postgres/* ./postgres/

ADD ./entrypoint.sh ./

CMD ["/app/entrypoint.sh"]