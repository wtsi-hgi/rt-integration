rt-integration
==============

Fetches tickets from RT (using REST API) and sends them to webhooks.


Running using docker
--------------------
You can run rt-agent directly from the 
[trusted docker build](https://index.docker.io/u/jrandall/rt-integration/)
without downloading the source at all. To do this, first pull the docker image:
```
docker pull jrandall/rt-integration
```

Then, to run rt-agent, you can either pass configuration information as command-line 
options:
```
docker run jrandall/rt-integration ./rt-agent.pl --rt_url http://rt.example.com/ --rt_username user --rt_password pass 
```

Or alternatively, you can write a configuration file and bind-mount it into the container:
```
docker run -v ~/.rt_agent:/etc/rt_agent.cfg jrandall/rt-integration ./rt-agent.pl
```
