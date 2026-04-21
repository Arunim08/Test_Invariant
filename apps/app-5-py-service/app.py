from flask import Flask, jsonify
import socket
import os
import time

app = Flask(__name__)
start_time = time.time()

@app.route('/')
def hello():
    return 'Hello from App-5 (Python Service)! 🔧\n'

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'app': 'app-5'})

@app.route('/status')
def status():
    uptime = time.time() - start_time
    return jsonify({
        'app': 'app-5',
        'type': 'Python Service',
        'hostname': socket.gethostname(),
        'uptime_seconds': int(uptime)
    })

@app.route('/ready')
def ready():
    return jsonify({'ready': True, 'app': 'app-5'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
