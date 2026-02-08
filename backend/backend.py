import logging
import logging_loki
import sentry_sdk
import os

from multiprocessing import Queue

from flask import Flask, jsonify, request

from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_client import make_wsgi_app, Summary
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)


logging_loki.emitter.LokiEmitter.level_tag = "level"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s',
    handlers=[
        # logging.FileHandler("app.log"),
        logging.StreamHandler(),
        logging_loki.LokiQueueHandler(
            Queue(-1),
            url="http://loki:3100/loki/api/v1/push",  # TODO: configure your own Loki instance address
            tags={"application": "backend-flask"},
            # auth=("870215", "configured"),          # TODO: configure your own Loki instance auth
            version="1",
        ),
    ]
)

SENTRY_DSN = os.environ.get('SENTRY_DSN_BACKEND')

sentry_sdk.init(
    # DSN can be provided via the SENTRY_DSN_BACKEND environment variable
    dsn=SENTRY_DSN,
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for tracing.
    traces_sample_rate=1.0,
    _experiments={
        # Set continuous_profiling_auto_start to True
        # to automatically start the profiler on when
        # possible.
        "continuous_profiling_auto_start": True,
    },
)

# Add prometheus wsgi middleware to route /metrics requests
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})
# Create a metric to track time spent and requests made.
REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')

"""
    Logs the incoming request information.
"""
@app.before_request
def log_request_info():
    logging.info(f"Request: {request.method} {request.url} {request.data}")

"""
Logs the outgoing response information.
"""
@app.after_request
def log_response_info(response):
    logging.info(f"Response: {response.status} {response.get_data(as_text=True)}")
    return response

"""
 Home page
"""
@REQUEST_TIME.time()
@app.route('/')
def home():
    return "<h1>Welcome!</h1>", 200

"""
Simulate a login
"""
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")
    if username == "test" and password == "password":
        return jsonify({"message": "Login successful", "token": "abc123"}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401

"""
Simulate fetching data
"""
@app.route('/api/data', methods=['GET'])
def fetch_data():
    return jsonify({"data": "Here is some data!"}), 200

"""
Simulate submitting data
"""
@app.route('/api/data', methods=['POST'])
def submit_data():
    data = request.get_json()
    return jsonify({"message": "Data submitted successfully", "submitted_data": data}), 201


"""
Simulate an error
"""
@app.route('/api/error', methods=['POST'])
def trigger_error():
    try:
        1/0
    except Exception as e:
        logging.error(f"Simulated error", exc_info=e)
        sentry_sdk.capture_exception(e)
    return jsonify({"error": "This is a simulated error"}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)