from services import queue_service
from services.logger_service import logger


def main():
    queue_service.start_queue()


if __name__ == '__main__':

    logger.info("launching lieferantenservice")
    try:
        main()
    except KeyboardInterrupt:
        logger.info("goodbye")
