# dns-over-tls
**Dns-over-tls on kubernetes**
====================================
DNS-Over-TLS server is used to send DNS queries over an encrypted connection(dns over tls), by default, DNS query is sent over the plain text connection. This is to design and develop a DNS proxy. A DNS proxy is a DNS forwarder that acts as a DNS resolver for client programs but requires an upstream DNS server, Cloudflare DNS server is used in this project as upstream DNS server, to perform the DNS lookup. It receives queries from the clients and forward it to the cloudflare DNS server for the results.

And also I have demonstrated , how to integrate the same on kubernetes cluster with coredns as dns resolver.

**Getting Started**
====================================
**Source code: dns-over-tls.py**

Code is written in Python3.7

In this server, I have used Cloudflare dns-over-tls (1.1.1.1)(public dns sever) for quering the client requests.

•	It will create a socket connection and bind it with the Docker's network (172.168.1.2) on port 53.

•	Receive UDP DNS requests on this connection and create a thread for the request and run request handler.

•	RequestHandler will call the function to create TLS connection cloudflare dns server on port 853 using self-signed certificate and after that convert UDP request into TCP DNS query and send it to Cloudflare DNS server over the tcp connection, when the server got TCP answer from Cloudflare DNS server, it will convert it into UDP and respond to the client over the same Docker network socket connection.

•	Currently, It is handling nslookup and dig requests.

**Installing**
======================================================================
**To run this project:**

•	Create docker image by using Dockerfile which is in the root directory by run this command:

    o	docker build -t dns-over-tls .
    
•	Create docker network by using this command:

    o	docker network create --subnet 172.168.1.0/24 testNetwork
    
•	Run the container by using that docker image we created in the previous step by run this command:

    o	docker run --net testNetwork -it dns-over-tls
    
•	Update your /etc/resolv.conf file for the nslookup by adding the nameserver entry:

    o	nameserver 172.168.1.2 #container local ip
    
•	You can test this by making nslookup or dig request

    o	nslookup yahoo.com
    o	dig @172.168.1.2 -p 53 google.com
    
•	On successful response server will give 200 response code.


**Security concerns**
======================================================
**Imagine this proxy being deployed in an infrastructure. What would be the security
concerns you would raise?.**

As cloudflare is public dns sever and there could be fishing activities will be there on over pulic server.

And we are using TLS/TCP to secure our pipelines and send DNS queries over those encrypted pipeline.

But there are also some known security concerns with TLS, when browser send request to the DNS proxy server and then proxy server will create TCP connection with Upstream DNS server, man-in-the-middle can spoof traffic between browser and dns server and send it over the TCP connection.

And some could get access to the buffer also to get the stored/cached information about the domain names. Also, there are some OpenSSL concerns involved but it can overcome by using the proper keys and signed certificates.


**Microservices Architecture or Distributed Environment**
===============================================================
**How would you integrate that solution in a distributed, microservices-oriented and
containerized architecture?**

In dirtibuted environment and micro service oriented architecture , while integrating and service, should not be an impact to any of the services and I have used coredns here to ingetrate cloudflare server on kubernetes cluster.

In coredns/kubedns which will running multiple pods to resolove the dns querries.

The main file for coredns is Corefile , which will be having all configuration details , like dns server and resolv.conf file and dns cache.

###
# /etc/coredns/Corefile

forward . tls://1.1.1.1 tls://1.0.0.1 {

    tls_servername cloudflare-dns.com
    
    health_check 5s
    
    log
    
    errors
    
    cache
    
    reload
}
 
 Once we add into dns server on corefile , which will atomatically add cloudflare dns server on pod level or container level , which is on /etc/resolv.conf file.
 without down time ,we can integrate cloudflare dns server on kubernetes cluster.

**Improvements**
=============================================
**There are alot more things that we can add in this project:**

Caching feature (store new results into the buffer for the better performance)

Can reduce overhead of TLS connection and the handshake process again and again on each request, by checking the client addr. Application should have to maintain the socket connections for the specific time period.

We can use DNSSEC and WARP on top of cloudflare dns server for faster processing and security.

Cloudfare is like a CDN so it continue to server cached versions of your webpages.

We can also add other available DNS-over-TLS servers like Quad9 and Cleanbrowsing.

Handle requests from browser directly, by updating the iptables may be or adding our own proxy ip in the browser settings.

Block ip, if dns server is getting too much requests from the same ip in the specific time period.
