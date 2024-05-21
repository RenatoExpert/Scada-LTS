FROM python:3.11.9-alpine3.19
RUN pip install cryptography lxml pytz
RUN pip install opcua
WORKDIR /server
COPY main.py .
CMD python3 /server/main.py

