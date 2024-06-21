from flask import Flask, render_template, jsonify, request
import json
import os

app = Flask(__name__)

def load_json(file_path):
    try:
        with open(file_path) as f:
            return jsonify(json.load(f))
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    return load_json('/data/health_status.json')

@app.route('/events')
def events():
    return load_json('/data/events.json')

@app.route('/recommendations')
def recommendations():
    return load_json('/data/vm_recommendations.json')

@app.route('/resource_utilization')
def resource_utilization():
    return load_json('/data/resource_utilization.json')

@app.route('/zombie_files')
def zombie_files():
    return load_json('/data/zombie_files.json')

@app.route('/search')
def search():
    query = request.args.get('q')
    results = []
    try:
        with open('/data/vm_recommendations.json') as f:
            data = json.load(f)
            for item in data:
                if query.lower() in item['VMName'].lower():
                    results.append(item['VMName'])
        return jsonify(results)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)