FROM python:3.11.9-alpine3.19
EXPOSE 4840
RUN pip install cryptography lxml pytz
RUN pip install asyncua
RUN pip install opcua
WORKDIR /server
COPY . .
RUN python3 certificate_gen.py
CMD python3 -u /server

