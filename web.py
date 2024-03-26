
from flask import Flask
from flask import render_template
import os   # If the pods are not commig up remove import os

app = Flask(__name__)

@app.route("/")
def home():
    return "Test Message Successful"

if __name__ == "_main_":
    app.run(host='0.0.0.0')