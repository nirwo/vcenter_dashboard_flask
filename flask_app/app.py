from flask import Flask, render_template, jsonify, request
import json

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    with open('/data/health_status.json') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/events')
def events():
    with open('/data/events.json') as f):
        data = json.load(f)
    return jsonify(data)

@app.route('/recommendations')
def recommendations():
    with open('/data/vm_recommendations.json') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/resource_utilization')
def resource_utilization():
    with open('/data/resource_utilization.json') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/zombie_files')
def zombie_files():
    with open('/data/zombie_files.json') as f):
        data = json.load(f)
    return jsonify(data)

@app.route('/search')
def search():
    query = request.args.get('q')
    results = []
    with open('/data/vm_recommendations.json') as f:
        data = json.load(f)
        for item in data:
            if query.lower() in item['VMName'].lower():
                results.append(item['VMName'])
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True)
