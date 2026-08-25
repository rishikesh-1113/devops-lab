from flask import Flask

app = Flask(__name__)


@app.route('/')
def home():
    return "Hello from Flask on Kubernetes!"


if __name__ == '__main__':
    # 0.0.0.0 so the app is reachable from outside the container,
    # 15000 is the containerPort / targetPort used in the YAML
    app.run(host='0.0.0.0', port=15000)
