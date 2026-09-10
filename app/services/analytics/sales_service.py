from app.repositories.mongodb.sales_repository import SalesRepository




class AnalyticsService:


    def __init__(self):


        self.repository = SalesRepository()


    def calculate_total_sales(self):


        sales = self.repository.get_all_sales()


        total = 0


        for sale in sales:


            total += sale["total_amount"]




        return {
            "indicator_name": "Total Sales",
            "total_sales": total,
            "currency": "PEN"
        }
