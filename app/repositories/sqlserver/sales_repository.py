from app.database.sqlserver import get_sqlserver_connection


class SalesRepository:
    """
    Repositorio para consultas de ventas en SQL Server.
    """
    
    def get_total_sales(self, year=None, month=None):
        query = """
            SELECT COALESCE(SUM(total_amount), 0)
            FROM sales
        """
        
        conditions = []
        params = []
        
        if year is not None:
            conditions.append("YEAR(sale_date) = ?")
            params.append(year)
        
        if month is not None:
            conditions.append("MONTH(sale_date) = ?")
            params.append(month)
        
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
        
        connection = get_sqlserver_connection()
        
        try:
            cursor = connection.cursor()
            cursor.execute(query, params)
            result = cursor.fetchone()
            
            # Convertir Decimal a float para facilitar
            # la serialización JSON en Flask.
            return float(result[0] or 0)
        
        finally:
            connection.close()
