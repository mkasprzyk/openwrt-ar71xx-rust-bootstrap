FROM ubuntu:16.04

COPY bootstrap.sh /bootstrap.sh
RUN bash /bootstrap.sh
