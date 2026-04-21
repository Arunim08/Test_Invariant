from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from App-4 (Python Flask API)! 🐍\n'

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'app': 'app-4'})

@app.route('/info')
def info():
    hostname = socket.gethostname()
    return jsonify({
        'app': 'app-4',
        'type': 'Python Flask API',
        'hostname': hostname,
        'version': '1.0'
    })

@app.route('/data')
def data():
    return jsonify({
        'app': 'app-4',
        'message': 'Data endpoint',
        'pid': os.getpid()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
