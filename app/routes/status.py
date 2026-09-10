from flask import Blueprint


status_bp = Blueprint("status", __name__)




@status_bp.route("/")
def inicio():
    return {
        "estado": " Operativo",
        "servicio": "Backend Analítico",
        "mensaje": "API funcionando correctamente 🚀"
    }
