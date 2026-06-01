FROM python:3.12-slim

WORKDIR /app

# Crear usuario no-root
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Instalar dependencias como root (necesario para pip)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código y asignar permisos al usuario
COPY . .
RUN chown -R appuser:appgroup /app

# Cambiar al usuario no-root
USER appuser

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]