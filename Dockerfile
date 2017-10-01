FROM python:3.6-alpine

RUN mkdir -p /application

COPY requirements.txt /application/

RUN apk --update add --virtual build-dependencies python-dev build-base gcc libc-dev linux-headers wget \
  && pip install -r /application/requirements.txt \
  && apk del build-dependencies

WORKDIR /application
COPY ./src /application/

ENV PORT 8888

EXPOSE ${PORT}

ARG GIT_COMMIT=unknown
LABEL git-commit=$GIT_COMMIT
ARG GIT_BRANCH=unknown
LABEL git-branch=$GIT_BRANCH
ARG BUILD_TIME=unknown
LABEL build_time=$BUILD_TIME

CMD uwsgi --http :${PORT}  --manage-script-name --mount /application=flask_app:app --enable-threads --processes 5
