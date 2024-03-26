FROM python:3.10.10-bullseye

RUN mkdir /app/

COPY . /app/
WORKDIR /app/
RUN pip install flask

CMD ["python","web.py"]
