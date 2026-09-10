from app.database.mongodb import get_database


class SalesRepository:


    def get_all_sales(self):


        db = get_database()


        collection = db["sales"]


        return list(collection.find())
