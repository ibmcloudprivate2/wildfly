# wildfly

# Dockerfile

```
FROM jboss/wildfly
 ADD helloworld.war /opt/jboss/wildfly/standalone/deployments/
```

## build docker image

```
docker build . -t mtl-helloworld
```

## test the image

```
docker run -p 5000:8080 mtl-helloworld
```

## access the app

```
$ curl -I http://localhost:5000
```

use browser to access and you should see **Hello World!**
```
http://localhost:5000/helloworld/HelloWorld
```

expected output
```
HTTP/1.1 200 OK
Connection: keep-alive
Last-Modified: Thu, 01 Mar 2018 06:29:00 GMT
X-Powered-By: Undertow/1
Server: WildFly/11
Content-Length: 2438
Content-Type: text/html
Accept-Ranges: bytes
Date: Wed, 11 Apr 2018 10:47:11 GMT
```

# config hostname in /etc/hosts
ensure your /etc/hosts file has the IP that map to the ICP cluster name

e.g.

192.168.64.148 mycluster.icp

## push image to ICP repo

### create a namespace
create a namespace of your choice in ICP using UI or kubectl

e.g. dev

### tag the image
```
docker tag mtl-helloworld mycluster.icp:8500/dev/mtl-helloworld:1.0
```

### login to docker
```
docker login mycluster.icp:8500
```

### push the image
```
docker push mycluster.icp:8500/dev/mtl-helloworld:1.0
```

# Helm Chart

## create helm chart
```
helm create myapp
```

## package the chart
```
helm package ./myapp
```

# Deploy the app using ICP Catalog

## add demo charts to ICP catalog
helm add ```https://ibmcloudprivate2.github.io/mycharts```
![./img/helm-repo.png]

## catalog
![./img/demo-chart.png]
![./img/repo-image.png]

## configure chart
![./img/configure-chart.png]

## install chart
![./img/install-chart.png]

## app output
![./img/app-homepage.png]
![./img/app-helloworld.png]







# Reference

[refer to dotnet app sample for more docker command](https://github.com/ibmcloudprivate2/dotnet/tree/master/samples/sample_aspnetmvc)