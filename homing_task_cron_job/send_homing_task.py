from rabbit_controller import RabbitController


rabbitmq = RabbitController(
    "amqp://admin:admin@localhost:5672/?heartbeat=600&blocked_connection_timeout=300"
)

rabbitmq.produce(
    queue_name="homing",
    value="homing",
)
