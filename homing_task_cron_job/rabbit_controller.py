from pika import URLParameters, BlockingConnection


class RabbitController:
    def __init__(self, url):
        self.__params = URLParameters(url=url)

    def produce(self, queue_name: str, value: int):
        with BlockingConnection(self.__params) as conn:
            channel = conn.channel()
            channel.queue_declare(queue_name, durable=True)
            channel.basic_publish(exchange="", routing_key=queue_name, body=f"{value}")
