from app.repositories.sqlserver.sales_repository import SalesRepository
from app.schemas.sales_schema import IndicatorResponse


class AnalyticsService:
    
    def __init__(self):
        self.repository = SalesRepository()
    
    def total_sales(self, year=None, month=None):
        result = self.repository.get_total_sales(
            year=year,
            month=month
        )
        
        return IndicatorResponse(
            indicator="sales_total",
            title="Ventas Totales",
            chart_type="card",
            data=result,
            sources=["SQL Server"]
        )
