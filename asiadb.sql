-- =============================================
-- BORRAR Y RECREAR LA BASE DE DATOS
-- =============================================

-- Cambiar a master para poder borrar la base de datos
USE master;
GO

-- Cerrar todas las conexiones activas a la base de datos
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AsiaMarket_Transactional')
BEGIN
    ALTER DATABASE AsiaMarket_Transactional SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AsiaMarket_Transactional;
END
GO

-- Crear la base de datos desde cero
CREATE DATABASE AsiaMarket_Transactional;
GO

USE AsiaMarket_Transactional;
GO

-- Crear la tabla sales
CREATE TABLE sales (
    sale_id VARCHAR(20) PRIMARY KEY,
    sale_date DATE NOT NULL,
    customer_id VARCHAR(10) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    region VARCHAR(50) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL
);
GO

-- Crear la tabla sales_detail
CREATE TABLE sales_detail (
    sale_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);
GO

SET NOCOUNT ON;

-- =============================================
-- GENERAR 1,000 VENTAS NUEVAS (2022-2026)
-- =============================================

IF OBJECT_ID('tempdb..#SalesBase') IS NOT NULL
    DROP TABLE #SalesBase;

IF OBJECT_ID('tempdb..#GeneratedDetails') IS NOT NULL
    DROP TABLE #GeneratedDetails;

IF OBJECT_ID('tempdb..#SalesTotals') IS NOT NULL
    DROP TABLE #SalesTotals;

;WITH Numeros AS
(
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
Fechas AS
(
    SELECT
        n,
        DATEADD(
            DAY,
            (n * 7) % DATEDIFF(
                DAY,
                CONVERT(date, '20220101'),
                CONVERT(date, '20261027')
            ),
            CONVERT(date, '20220101')
        ) AS sale_date
    FROM Numeros
)
SELECT
    n,
    CONCAT(
        'S',
        RIGHT(CONVERT(varchar(4), YEAR(sale_date)), 2),
        RIGHT('000000' + CONVERT(varchar(6), n), 6)
    ) AS sale_id,
    sale_date,

    CONCAT(
        'C',
        RIGHT('000' + CONVERT(varchar(3), ((n - 1) % 8) + 1), 3)
    ) AS customer_id,

    CASE n % 3
        WHEN 0 THEN 'Online'
        WHEN 1 THEN 'Tienda'
        ELSE 'Marketplace'
    END AS channel,

    CASE n % 6
        WHEN 0 THEN 'Lima'
        WHEN 1 THEN 'Arequipa'
        WHEN 2 THEN 'Cusco'
        WHEN 3 THEN 'Ica'
        WHEN 4 THEN 'Puno'
        ELSE 'Moquegua'
    END AS region,

    CASE n % 5
        WHEN 0 THEN 'Tarjeta'
        WHEN 1 THEN 'Efectivo'
        WHEN 2 THEN 'Yape'
        WHEN 3 THEN 'Plin'
        ELSE 'Transferencia'
    END AS payment_method

INTO #SalesBase
FROM Fechas;

-- =============================================
-- GENERAR ENTRE 2 Y 3 DETALLES POR VENTA
-- =============================================

SELECT
    s.sale_id,

    CONCAT(
        'P',
        RIGHT(
            '000' + CONVERT(
                varchar(3),
                ((s.n + v.line_no * 2) % 6) + 1
            ),
            3
        )
    ) AS product_id,

    x.quantity,
    x.unit_price,

    CAST(
        x.quantity * x.unit_price
        AS DECIMAL(10,2)
    ) AS subtotal

INTO #GeneratedDetails
FROM #SalesBase s

CROSS JOIN (VALUES (1), (2), (3)) v(line_no)

CROSS APPLY
(
    SELECT
        1 + ((s.n + v.line_no) % 5) AS quantity,

        CAST(
            25.00
            + ((s.n * 13 + v.line_no * 17) % 275)
            + (v.line_no * 0.25)
            AS DECIMAL(10,2)
        ) AS unit_price
) x

WHERE v.line_no <= 2 + (s.n % 2);

-- =============================================
-- CALCULAR EL TOTAL REAL DE CADA VENTA
-- =============================================

SELECT
    sale_id,
    CAST(SUM(subtotal) AS DECIMAL(10,2)) AS total_amount
INTO #SalesTotals
FROM #GeneratedDetails
GROUP BY sale_id;

-- =============================================
-- INSERTAR CABECERAS DE VENTAS
-- =============================================

INSERT INTO sales
(
    sale_id,
    sale_date,
    customer_id,
    channel,
    region,
    payment_method,
    total_amount
)
SELECT
    s.sale_id,
    s.sale_date,
    s.customer_id,
    s.channel,
    s.region,
    s.payment_method,
    t.total_amount
FROM #SalesBase s
INNER JOIN #SalesTotals t
    ON t.sale_id = s.sale_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales existing
    WHERE existing.sale_id = s.sale_id
);

-- =============================================
-- INSERTAR DETALLES DE VENTAS
-- =============================================

INSERT INTO sales_detail
(
    sale_id,
    product_id,
    quantity,
    unit_price,
    subtotal
)
SELECT
    d.sale_id,
    d.product_id,
    d.quantity,
    d.unit_price,
    d.subtotal
FROM #GeneratedDetails d
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales_detail existing
    WHERE existing.sale_id = d.sale_id
);

-- =============================================
-- VERIFICAR RESULTADOS POR AÑO
-- =============================================

SELECT
    YEAR(sale_date) AS anio,
    COUNT(*) AS cantidad_ventas,
    SUM(total_amount) AS total_vendido,
    AVG(total_amount) AS ticket_promedio
FROM sales
GROUP BY YEAR(sale_date)
ORDER BY anio;

-- =============================================
-- VERIFICAR CANTIDAD DE REGISTROS
-- =============================================

SELECT
    (SELECT COUNT(*) FROM sales) AS total_ventas,
    (SELECT COUNT(*) FROM sales_detail) AS total_detalles;

GO

—--- Total histórico
SELECT
    COALESCE(SUM(total_amount), 0) AS total_sales
FROM sales;


—--- Total de un año
SELECT
    COALESCE(SUM(total_amount), 0) AS total_sales
FROM sales
WHERE YEAR(sale_date) = 2026;


—--- Total de octubre de todos los años
SELECT
    COALESCE(SUM(total_amount), 0) AS total_sales
FROM sales
WHERE MONTH(sale_date) = 10;


—---- Total de octubre de 2026
SELECT
    COALESCE(SUM(total_amount), 0) AS total_sales
FROM sales
WHERE YEAR(sale_date) = 2026
  AND MONTH(sale_date) = 10;
