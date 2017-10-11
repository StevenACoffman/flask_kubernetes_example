# if you're doing anything beyond your local machine, please pin this to a specific version at https://hub.docker.com/_/python/
# format is python:${PYTHON_VER}-alpine${ALPINE_VER}
FROM python:3.6-alpine3.6

WORKDIR /application

# Install dependencies first, add code later, for layering
COPY requirements.txt .

# tini and su-exec because both PID 1 and root are special

# --no-cache option preferred over --update

RUN apk add --no-cache su-exec tini \
  && apk --no-cache add --virtual build-dependencies python3-dev build-base gcc libc-dev linux-headers wget \
  && pip install -r /application/requirements.txt \
  && apk del build-dependencies

# Add your source files
COPY ./src .

# Build arguments may change independent of source code, order after

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

# replace this with your application's default port
ENV PORT 8888

EXPOSE ${PORT}

# Without tini, PID as 1 leaves orphan processes
# Set tini as the default entrypoint
ENTRYPOINT ["tini", "--"]

CMD uwsgi --http :${PORT}  --manage-script-name --mount /application=flask_app:app --enable-threads --processes 5
