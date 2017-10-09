FROM python:3.6-alpine

RUN mkdir -p /application

COPY requirements.txt /application/

# --no-cache option preferred over --update

RUN apk add --no-cache su-exec tini
  && apk --no-cache add --virtual build-dependencies python3-dev build-base gcc libc-dev linux-headers wget \
  && pip install -r /application/requirements.txt \
  && apk del build-dependencies

WORKDIR /application
COPY ./src /application/

ENV PORT 8888

EXPOSE ${PORT}

ARG GIT_REPO="unknown"
ARG GIT_COMMIT="unknown"
ARG GIT_BRANCH="unknown"
ARG BUILD_TIME="unknown"

LABEL name="Flask Kubernetes Example" \
  maintainer="StevenACoffman" \
  git-repo="$GIT_REPO" \
  git-commit="$GIT_COMMIT" \
  git-branch="$GIT_BRANCH" \
  version="$GIT_COMMIT" \
  build_time="$BUILD_TIME" \
  description="Example Flask app with Prometheus for Kubernetes"

# Set tini as the default entrypoint
ENTRYPOINT ["tini", "--"]

CMD uwsgi --http :${PORT}  --manage-script-name --mount /application=flask_app:app --enable-threads --processes 5
