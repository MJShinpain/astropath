from flask import Flask, request, jsonify
from calculate_venus import calculate_venus_positions
import traceback

app = Flask(__name__)

@app.route('/calculate_venus', methods=['POST'])
def calculate_venus():
    try:
        print("Received request for Venus calculation")
        data = request.json
        print(f"Received data: {data}")
        
        latitude = float(data['latitude'])
        longitude = float(data['longitude'])
        date_str = data['date']
        time_str = data['time']
        
        results = calculate_venus_positions(latitude, longitude, date_str, time_str)
        print(f"Calculation results: {results}")
        return jsonify(results)
    except Exception as e:
        print(f"Error in calculation: {str(e)}")
        print(traceback.format_exc())
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')