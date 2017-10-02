# Example Flask app with Prometheus on Kubernetes

See ``src`` for the application code.

Note: Adapted for Kubernetes from Swarm example code here: [python-prometheus-demo](https://github.com/amitsaha/python-prometheus-demo/). Original [swarm prometheus article](https://blog.codeship.com/monitoring-your-synchronous-python-web-applications-using-prometheus/?utm_content=58060028&utm_medium=social&utm_source=twitter) here.

Run this locally in docker:
```bash
docker run -p 8888:8888 stevenacoffman/flask_kubernetes_example
```

Apply this to your Kubernetes cluster (Note: cluster not included):
```bash
kubectl apply -f flask-example.yaml
```

## Building Docker image

The Python 3 based [Dockerfile](Dockerfile) uses an Alpine Linux base image
and expects the application source code to be volume mounted at `/application`
when run:

```
FROM python:3.6.1-alpine
ADD . /application
WORKDIR /application
RUN set -e; \
	apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		linux-headers \
	; \
	pip install -r src/requirements.txt; \
	apk del .build-deps;
EXPOSE 8888
VOLUME /application
CMD uwsgi --http :8888  --manage-script-name --mount /application=flask_app:app --enable-threads --processes 5
```

The last statement shows how we are running the application via `uwsgi` with 5
worker processes.

To build the image:

```
$ docker build -t stevenacoffman/flask_kubernetes_example .
```

## Running the application

We can just run the web application as follows:

```
$ docker run  -ti -p 8888:8888 stevenacoffman/flask_kubernetes_example
```

## Running the application via compose

See the compose directory for a way to run the flask app and a prometheus server locally via docker compose

## Running the application via Kubernetes

kubectl apply -f flask-k8s.yaml
