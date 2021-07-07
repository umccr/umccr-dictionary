FROM python:3.7-slim
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
COPY . /importer
WORKDIR /importer
RUN pip install --no-cache-dir .
VOLUME ["/importer/output","/importer/data","/importer/schema"]
CMD [ "importer", "--help" ]
