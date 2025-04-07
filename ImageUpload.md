# Image upload via REST API

```console
 curl -v -X POST \
  -H "X-Parse-Application-Id: {APPLICATION_ID}" \
  -H "X-Parse-REST-API-Key: {API-KEY}" \
  -H "Content-Type: image/png" \
  --data-binary '@Privacy_Location_1.png' \
  'https://parse-dev.solingen.de/parse/files/Privacy_Location_1.png'

```

Return from Server:

```console
*   Trying 195.243.56.42:443...
* Connected to parse-dev.solingen.de (195.243.56.42) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*  CAfile: /etc/ssl/cert.pem
*  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: C=DE; O=Kommunales-Rechenzentrum-Niederrhein; OU=Stadt Solingen; ST=NRW; L=Kamp-Lintfort; CN=*.solingen.de
*  start date: Apr 20 12:08:31 2020 GMT
*  expire date: Apr 25 23:59:59 2022 GMT
*  subjectAltName: host "parse-dev.solingen.de" matched cert's "*.solingen.de"
*  issuer: C=DE; O=T-Systems International GmbH; OU=T-Systems Trust Center; ST=Nordrhein Westfalen; postalCode=57250; L=Netphen; street=Untere Industriestr. 20; CN=TeleSec ServerPass Class 2 CA
*  SSL certificate verify ok.
> POST /parse/files/Privacy_Location_1.png HTTP/1.1
> Host: parse-dev.solingen.de
> User-Agent: curl/7.77.0
> Accept: */*
> X-Parse-Application-Id: ****
> X-Parse-REST-API-Key: ****
> Content-Type: image/png
> Content-Length: 735976
> 
* We are completely uploaded and fine
* Mark bundle as not supporting multiuse
< HTTP/1.1 400 Bad Request
< Date: Fri, 04 Mar 2022 09:48:24 GMT
< Server: Apache
< Strict-Transport-Security: max-age=31536000; includeSubdomains;
< X-Powered-By: Express
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Methods: GET,PUT,POST,DELETE,OPTIONS
< Access-Control-Allow-Headers: X-Parse-Master-Key, X-Parse-REST-API-Key, X-Parse-Javascript-Key, X-Parse-Application-Id, X-Parse-Client-Version, X-Parse-Session-Token, X-Requested-With, X-Parse-Revocable-Session, X-Parse-Request-Id, Content-Type, Pragma, Cache-Control
< Access-Control-Expose-Headers: X-Parse-Job-Status-Id, X-Parse-Push-Status-Id
< Content-Type: application/json; charset=utf-8
< Content-Length: 54
< ETag: W/"36-c5i63FpFfG5ymhT5OitNbg/B10g"
< Connection: close
< 
* Closing connection 0
* TLSv1.2 (OUT), TLS alert, close notify (256):
{"error":"Unexpected token � in JSON at position 0"}%    
```
