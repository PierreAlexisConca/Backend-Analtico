from flask import Flask


from app.routes.status import status_bp
from app.routes.sales_analytics import analytics_bp
from app.config.swagger import swagger_bp


app = Flask(__name__)


app.json.ensure_ascii = False


app.register_blueprint(status_bp)


app.register_blueprint(analytics_bp)


app.register_blueprint(swagger_bp)


if __name__ == "__main__":


    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
