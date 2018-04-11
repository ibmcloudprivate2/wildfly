# wildfly

# Dockerfile

```
FROM jboss/wildfly
 ADD helloworld.war /opt/jboss/wildfly/standalone/deployments/
```

## build docker image

```
docker build . -t wfhelloworld
```

## test the image

```
docker run -p 5000:8080 wfhelloworld
```

## access the app

```
curl -I http://localhost:5000
```


# Reference

[refe to dotnet app sample for more docker command](https://github.com/ibmcloudprivate2/dotnet/tree/master/samples/sample_aspnetmvc)