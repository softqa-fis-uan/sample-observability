from flask import Flask, jsonify, request
import logging

import sentry_sdk
from flask import Flask

sentry_sdk.init(
    # TODO: Replace the DSN below with your own DSN to see the events in your Sentry project
    dsn="https://123456789.ingest.us.sentry.io/123456789",
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


app = Flask(__name__)

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s',
    handlers=[
        logging.FileHandler("app.log"),
        logging.StreamHandler()
    ]
)
"""
    Logs the incoming request information.
"""
@app.before_request
def log_request_info():
    logging.debug(f"Request: {request.method} {request.url} {request.data}")

"""
Logs the outgoing response information.
"""
@app.after_request
def log_response_info(response):
    logging.debug(f"Response: {response.status} {response.get_data(as_text=True)}")
    return response

"""
 Home page
"""
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
    data = request.get_json()
    logging.error(f"Simulated error: {data}")
    1/0
    return jsonify({"error": "This is a simulated error"}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)