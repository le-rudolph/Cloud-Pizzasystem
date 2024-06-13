import pika
import os

QUEUE_HOST = os.environ["QUEUE_HOST"]


def receive_order(channel, method, properties, body):
    print(channel, method, properties, body)
    print(f"received order {body}")


def main():
    print(f"connecting to queue at {QUEUE_HOST}")
    connection = None
    retries = 5
    while retries > 0:
        try:
            connection = pika.BlockingConnection(
                pika.ConnectionParameters(host=QUEUE_HOST))
        except pika.exceptions.AMQPConnectionError:
            retries -= 1
            print(f"queue is down, {retries} remaining")

    if connection is None:
        raise RuntimeError("could not connect to queue")

    channel = connection.channel()

    channel.queue_declare(
        queue="order", on_message_callback=receive_order, auto_ack=True)

    print("waiting for order")
    channel.start_consuming()


if __name__ == '__main__':
    print("launching lieferantenservice")
    try:
        main()
    except pika.exceptions.AMQPConnectionError as e:
        print("queue is down")
    except KeyboardInterrupt:
        print("goodbye")
