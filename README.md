# wildfly

This is a project demonstrated steps to dockerize a [helloworld](https://github.com/wildfly/quickstart/tree/master/helloworld) application from the wildfly [quickstart](https://github.com/wildfly/quickstart) projects.

I would also recommend looking at [Microservice Builder](https://www.ibm.com/support/knowledgecenter/en/SS5PWC/index.html) and also the next generatio of application development [microclimate](https://microclimate-dev2ops.github.io/.

Microservice Builder is about focus on app development and not the framework where you can used to develop Java EE and [MicroProfile.io](http://microprofile.io/) based programming model.

# Dockerfile
To dockerize your web application create a Dockerfile with the following content.

Ensure your web applicatin **.war** is located in the same folder as the Dockerfile.

```
FROM jboss/wildfly
 ADD helloworld.war /opt/jboss/wildfly/standalone/deployments/
```

## build docker image
Run the following command to create docker image locally on your machine.

```
docker build . -t mtl-helloworld
```

# to list the docker images
To list the docker images on your machine, execute the following command.

```
docker images
```

## test the image
To test the application dockerize above, you can run your application with the following command.

The command execute the container at port 5000 and you can access your application at ```http://localhost:5000```

```
docker run -p 5000:8080 mtl-helloworld
```

## access the app
alternatively you can test with curl.
```
$ curl -I http://localhost:5000

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

You can also view the **helloworld** application with the below url.

```
http://localhost:5000/helloworld/HelloWorld
```

## to list running container
To see the running containers, you can use the following command

```
docker ps

or 

docker ps -l
```

# config hostname in /etc/hosts
In order for you to push your local image to ICP, you need to add a IP entry in your host file ```/etc/hosts```

assuming your ICP instance has
IP : 192.168.64.148
cluster : mycluster.icp

Please create the following line in your ```/etc/hosts```
```
192.168.64.148 mycluster.icp
```

## push image to ICP repo

### create a namespace
You can push images to a specific namespae in ICP. 

For example, if you want to push your image to a namespace 
create a namespace of your choice in ICP using UI or kubectl

e.g. using kubectl, to use kubectl you will need to [configure](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/manage_cluster/cfc_cli.html) your client to connect to ICP.

```
kubectl create namespace dev
```

### tag the image

With the following command you have
- namespace : **dev**
- tag: **1.0**
- image: **mtl-helloworld**
- ICP cluster repo : **mycluster.icp:8500**

```
docker tag mtl-helloworld mycluster.icp:8500/dev/mtl-helloworld:1.0
```

### login to docker
Before you can push the image to ICP private docker image repo, you need to perform docker login.

on my Mac machine, I login with secured login disable, where I can specify the location of in Daemon in docker engine for insecure registries.

For setup on Linux, please refer to [pushing and pulling](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/manage_images/using_docker_cli.html) image in ICP.

```
docker login mycluster.icp:8500
```

### push the image
```
docker push mycluster.icp:8500/dev/mtl-helloworld:1.0
```

# Helm Chart
You can create helm chart for your application where your users can deploy your application through the self service catalog provided by IBM Cloud Private.

To create a helm chart you can run the following command, I have updated the generated templates for **containerPort: 8080** in ```deployment.yaml```. In ```values.yaml``` I have updated the following.
```  
  repository: mycluster.icp:8500/dev/mtl-helloworld
  tag: "1.0"
```

## create helm chart
Create the helm chart template with the following command
```
helm create myapp
```

## package the chart
package your helm chart as a **.tgz** file.
```
helm package ./myapp
```

You can then place your tgz files on a web server with listing of all helm chart files.

For example, if you have a web server **https://url/mycharts** and your helm chart files are located at local folder charts. You create a index of your helm charts with the following command.

```
helm repo index charts --url https://url/mycharts
```

for reference to more [helm commands](https://docs.helm.sh/helm/#helm).

# Deploy the app using ICP Catalog
You can add your charts to ICP catalog using UI or helm command.

To learn more on using helm with ICP, check out setting up [Helm CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/app_center/create_helm_cli.html).

Once your chart repo is configured in ICP, your users will be able to deploy your application from ICP catalog.

## add demo charts to ICP catalog
helm add ```https://ibmcloudprivate2.github.io/mycharts```

![helmrepo](../master/img/helm-repo.png)

## catalog
![demochart](../master/img/demo-chart.png)
![repoimage](../master/img/repo-image.png)

## configure chart
![configchart](../master/img/configure-chart.png)

## install chart
![installchart](../master/img/install-chart.png)

## app output
![homepage](../master/img/app-homepage.png)
![helloworled endpoint](../master/img/app-helloworld.png)

# Reference

[refer to dotnet app sample for more docker command](https://github.com/ibmcloudprivate2/dotnet/tree/master/samples/sample_aspnetmvc)