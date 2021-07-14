FROM python:3.7-slim
ENV PYTHONUNBUFFERED 1
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
COPY . /importer
WORKDIR /importer
RUN pip install --no-cache-dir .
CMD [ "importer", "--help" ]
