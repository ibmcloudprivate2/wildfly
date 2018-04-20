# wildfly

This project demonstrate the steps to dockerize a [helloworld](https://github.com/wildfly/quickstart/tree/master/helloworld) application from the wildfly [quickstart](https://github.com/wildfly/quickstart) projects.

I would recommend looking at [Microservice Builder](https://www.ibm.com/support/knowledgecenter/en/SS5PWC/index.html) and also the next generation application development [microclimate](https://microclimate-dev2ops.github.io/.

Microservice Builder is about focus on app development and not the framework where you can used to develop Java EE and [MicroProfile.io](http://microprofile.io/) based programming model.

I have also created another [project](https://github.com/ibmcloudprivate2/openliberty) that's show how you would create the Dockerfile where the same web application can be deployed on WebSphere Liberty.

# Some references on using WebSphere Liberty

## Course : **Migrate traditional WebSphere apps to WebSphere Liberty on IBM Cloud Private by using Kubernetes**
- [Modernize an application to run on WebSphere Liberty](https://www.ibm.com/cloud/garage/content/course/websphere-on-cloud-private/1)
- [Locally build and run the WebSphere Liberty application](https://www.ibm.com/cloud/garage/content/course/websphere-on-cloud-private/2)
- [Containerize the WebSphere Liberty application](Containerize the WebSphere Liberty application)
- [Configure Kubernetes for WebSphere Liberty](https://www.ibm.com/cloud/garage/content/course/websphere-on-cloud-private/4)
- [Deploy the WebSphere Liberty application from the Kubernetes command line](https://www.ibm.com/cloud/garage/content/course/websphere-on-cloud-private/5)

## others
- [Migrating WebSphere apps to IBM Cloud Private](https://www.ibm.com/cloud/garage/videos/migrating-websphere-app-to-cloud)
- [Microservices for fast time to market and improved app quality](https://www.ibm.com/cloud/garage/architectures/microservices)
- [Private cloud for maximum control with the benefits of cloud](https://www.ibm.com/cloud/garage/architectures/private-cloud)

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

## delete your images

clean up the images locally
```
docker rm `docker ps --no-trunc -a -q`
docker images | grep '' | awk '{print $3}' | xargs docker rmi
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

You can also view the **helloworld** application with url the below.

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

# Test drive ICP
You can start test drive ICP using Terraform.

- [Deploy ICP on IBM Cloud](https://github.com/pjgunadi/ibm-cloud-private-terraform-softlayer)
- [Deploy ICP on vmware](https://github.com/pjgunadi/ibm-cloud-private-terraform-vmware)
- [Deploy ICP on AWS](https://github.com/pjgunadi/ibm-cloud-private-terraform-aws)

## Test CI/CD
Once you have your ICP, you can test drive CI/CD using GitLab and Jenkins.

- [test drive ci/cd](https://github.com/pjgunadi/discovery-news-demo)

## To quickly test drive some application
you can test drive some application by adding the the repo below to ICP catalog.

```
https://ibmcloudprivate2.github.io/mycharts/
```

With the above charts you can test drive deployment of sample application 

- [.NET Core 2.0 app](https://github.com/ibmcloudprivate2/dotnet)
- [Python Flask web app](https://github.com/ibmcloudprivate2/flask)
- [Wildfly web app](https://github.com/ibmcloudprivate2/wildfly)
- [Play framework app](https://github.com/ibmcloudprivate2/playframework)
- [angular admin application](https://github.com/ibmcloudprivate2/ng4-admin)

- short [video](https://www.youtube.com/playlist?list=PLJbpjOCY3AtW7KiSJKP6_YD9uXHfo1_KM) of ICP feature usage

# References

- [Getting started with reference architectures](https://www.ibm.com/cloud/garage/content/think/practice_get_started_with_architectures/)
- [Deploy a Spring Cloud application on IBM Cloud Private](https://www.ibm.com/cloud/garage/tutorials/cloud-private-spring-cloud/)
- [Microservices for fast time to market and improved app quality](https://www.ibm.com/cloud/garage/architectures/microservices)
- [Building Stock Trader in IBM Cloud Private 2.1 using Production Services](https://www.ibm.com/developerworks/community/blogs/5092bd93-e659-4f89-8de2-a7ac980487f0/entry/Building_Stock_Trader_in_IBM_Cloud_Private_2_1_using_Production_Services?lang=en)
- [twelve-factor app](https://12factor.net/)
- [Best practice for Dokcerfile](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Best practice for docker development](https://docs.docker.com/develop/dev-best-practices/)
- [refer to dotnet app sample for more docker command](https://github.com/ibmcloudprivate2/dotnet/tree/master/samples/sample_aspnetmvc)