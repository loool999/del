
from flask import Flask, send_from_directory, send_file, Response
import os
import logging

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

# Serve files from the project root so index.html and runner assets are available
ROOT_DIR = os.path.abspath(os.path.dirname(__file__))


@app.route('/')
def index():
    """Return the project's index.html for the root path.

    If index.html is missing, return a short diagnostic listing the files
    present in the application directory — useful when debugging container builds.
    """
    index_path = os.path.join(ROOT_DIR, 'index.html')
    logging.info("Request for / -> index at %s", index_path)
    if os.path.exists(index_path):
        return send_from_directory(ROOT_DIR, 'index.html')

    # Diagnostic response showing what exists in the root directory
    files = []
    try:
        files = sorted(os.listdir(ROOT_DIR))
    except Exception as e:
        logging.exception("Failed to list ROOT_DIR: %s", e)

    body = [f"index.html not found in {ROOT_DIR}", "", "Files:"]
    body += files
    return Response('\n'.join(body), mimetype='text/plain', status=500)

UNDERTALE_DIR = os.path.join(ROOT_DIR, 'undertale')

@app.route('/undertale/', defaults={'filename': 'index.html'})
@app.route('/undertale/<path:filename>')
def serve_undertale(filename):
    requested = os.path.join(UNDERTALE_DIR, filename)
    logging.info("Requested /undertale/%s -> resolved %s", filename, requested)
    if not os.path.exists(requested):
        logging.warning("File not found in undertale folder: %s", requested)
        return Response(f"File not found: {filename}\n", mimetype='text/plain', status=404)
    if filename.endswith('.wasm'):
        return send_file(requested, mimetype='application/wasm')
    return send_from_directory(UNDERTALE_DIR, filename)

@app.route('/index.html')
def index_html():
    return index()


@app.route('/<path:filename>')
def serve_file(filename):
    """Serve other files (JS, WASM, assets) from project root with logging.

    Special-case `.wasm` to ensure the correct MIME type when needed.
    """
    requested = os.path.join(ROOT_DIR, filename)
    logging.info("Requested file: %s -> resolved %s", filename, requested)
    if not os.path.exists(requested):
        logging.warning("File not found: %s", requested)
        return Response(f"File not found: {filename}\n", mimetype='text/plain', status=404)

    # For .wasm ensure the application/wasm MIME type
    if filename.endswith('.wasm'):
        return send_file(requested, mimetype='application/wasm')

    return send_from_directory(ROOT_DIR, filename)

PORT = int(os.environ.get("PORT", 8080))

if __name__ == "__main__":
    # Bind to 0.0.0.0 so containers can reach the server
    logging.info("Starting server, ROOT_DIR=%s", ROOT_DIR)
    app.run(host="0.0.0.0", port=PORT)