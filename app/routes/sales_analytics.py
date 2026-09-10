from flask import Blueprint, jsonify
from app.services.analytics.sales_service import AnalyticsService
analytics_bp = Blueprint(
    "analytics",
    __name__
)
service = AnalyticsService()
@analytics_bp.route(
    "/analytics/sales-total",
    methods=["GET"]
)
def sales_total():
    result = service.calculate_total_sales()
    return jsonify(result)
