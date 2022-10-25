FROM python:3.7
RUN apt-get update && apt-get install openssl && apt-get install dnsutils -y 
WORKDIR /usr/local/bin
COPY Dns-over-tls.py .
ENTRYPOINT ["python","Dns-over-tls.py"]
