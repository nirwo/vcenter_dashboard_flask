from flask import Flask, render_template, jsonify, request
import os
import json

app = Flask(__name__)

# Set the data directory
data_dir = '/data'

def load_json(filename):
    filepath = os.path.join(data_dir, filename)
    if os.path.exists(filepath):
        with open(filepath) as f:
            return json.load(f)
    else:
        return {"error": "File not found"}

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    data = load_json('health_status.json')
    return jsonify(data)

@app.route('/events')
def events():
    data = load_json('events.json')
    return jsonify(data)

@app.route('/recommendations')
def recommendations():
    data = load_json('vm_recommendations.json')
    return jsonify(data)

@app.route('/resource_utilization')
def resource_utilization():
    data = load_json('resource_utilization.json')
    return jsonify(data)

@app.route('/zombie_files')
def zombie_files():
    data = load_json('zombie_files.json')
    return jsonify(data)

@app.route('/search')
def search():
    query = request.args.get('q')
    results = []
    data = load_json('vm_recommendations.json')
    if "error" not in data:
        for item in data:
            if query.lower() in item['VMName'].lower():
                results.append(item['VMName'])
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')