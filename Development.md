== Development ==

To develop and test within the docker container (sorting out prerequisities using the Dockerfile), you could run a command like:

```
docker build -t local/rt-integration . && docker run -v ~/.rt_agent:/etc/rt_agent.cfg local/rt-integration ./rt-agent.pl
```

This command bind-mounts the ~/.rt_agent configuration file from your machine into the Docker container as /etc/rt_agent.cfg

