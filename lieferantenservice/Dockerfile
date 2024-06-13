FROM python:3.12-alpine
WORKDIR /service
ENV QUEUE_HOST="pizza-queue"
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY ./src/ /service/
CMD ["python", "lieferantenservice.py"]