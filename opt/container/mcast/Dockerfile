FROM python:3-alpine AS build
RUN apk add build-base linux-headers
RUN pip wheel netifaces

FROM python:3-alpine
RUN apk add bash vlan
COPY --from=build /netifaces*.whl /tmp
RUN pip install /tmp/netifaces*.whl
ADD --chmod=0755 multicast-relay.py /app/
ADD --chmod=0755 run.sh /app/

ENTRYPOINT ["/app/run.sh"]
