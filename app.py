import csv
from flask import Flask, jsonify

app = Flask(__name__)

# Load data from CSV file
data = []

with open('data.csv', 'r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        data.append({
            'date': row['Date'],
            'steps': int(row['Steps']),
            'distance': float(row['Distance']),
            'calories': int(row['Calories'])
        })

@app.route('/data', methods=['GET'])
def get_data():
    return jsonify({'data': data})

if __name__ == '__main__':
    app.run(debug=True)
