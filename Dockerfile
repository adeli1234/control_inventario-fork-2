FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# No correr como root dentro del contenedor
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
# Servidor de producción (en vez de app.run(debug=True))
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]
