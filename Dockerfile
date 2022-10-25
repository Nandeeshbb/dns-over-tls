FROM python:3.7
RUN apt-get install openssl
WORKDIR /usr/local/bin
COPY Dns-over-tls.py .
ENTRYPOINT ["python","myserver.py"]
