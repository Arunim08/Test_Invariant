from flask import Flask, jsonify
import socket
import psutil
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from App-6 (Python Monitor)! 📊\n'

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'app': 'app-6'})

@app.route('/metrics')
def metrics():
    cpu_percent = psutil.cpu_percent(interval=1)
    memory_info = psutil.virtual_memory()
    return jsonify({
        'app': 'app-6',
        'type': 'Python Monitor',
        'hostname': socket.gethostname(),
        'cpu_percent': cpu_percent,
        'memory_percent': memory_info.percent,
        'memory_available_mb': int(memory_info.available / 1024 / 1024)
    })

@app.route('/info')
def info():
    return jsonify({
        'app': 'app-6',
        'pid': os.getpid(),
        'version': '1.0'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
