
from flask import Flask, send_from_directory
import os

app = Flask(__name__)

# Serve files from the project root so index.html and runner assets are available
ROOT_DIR = os.path.abspath(os.path.dirname(__file__))


@app.route('/')
def index():
    """Return the project's index.html for the root path."""
    return send_from_directory(ROOT_DIR, 'index.html')


@app.route('/<path:filename>')
def serve_file(filename):
    """Serve other files (JS, WASM, assets) from project root."""
    return send_from_directory(ROOT_DIR, filename)


if __name__ == "__main__":
    # Bind to 0.0.0.0 so containers can reach the server
    app.run(host="0.0.0.0", port=8080)