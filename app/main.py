from flask import Flask
from app.routes.status import status_bp


app = Flask(__name__)


app.json.ensure_ascii = False


app.register_blueprint(status_bp)




if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )

