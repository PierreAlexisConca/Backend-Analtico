class IndicatorResponse:
    """
    Esquema estándar para respuestas de indicadores analíticos.
    Mantiene consistencia en todos los endpoints de analítica.
    """
    def __init__(self, indicator, title, chart_type, data, sources):
        self.indicator = indicator
        self.title = title
        self.chart_type = chart_type
        self.data = data
        self.sources = sources
