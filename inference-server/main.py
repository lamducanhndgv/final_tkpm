import os
from flask import Flask
from Command import run

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

app = Flask(__name__)
app.register_blueprint(run.run_model_page)


@app.route("/")
def index():
    return "<h1>Hello World</h1>"


if __name__ == "__main__":
    app.run("0.0.0.0", port=os.environ["APP_PORT"])
