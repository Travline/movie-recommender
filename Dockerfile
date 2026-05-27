# ==========================================
# ETAPA 1: Compilar Scala (Multi-stage)
# ==========================================
FROM hseeberger/scala-sbt:8u312_1.6.2_2.13.8 AS scala-builder
WORKDIR /build
COPY scala /build
RUN sbt assembly

# ==========================================
# ETAPA 2: Imagen Base Final (Estable y limpia)
# ==========================================
FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema: Python, SWI-Prolog y Java
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    swi-prolog \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

# Crear un enlace simbólico para poder usar 'python' en lugar de 'python3.11'
RUN ln -s /usr/bin/python3.11 /usr/bin/python

WORKDIR /app

# Copiar dependencias de Python e instalar
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar los recursos del proyecto
COPY pelis.csv .
COPY app/ ./app
COPY prolog/ ./prolog

# Copiar el JAR compilado desde la etapa de construcción de Scala
COPY --from=scala-builder /build/target/scala-2.13/movie-recommender-assembly-1.0.jar ./scala/target/scala-2.13/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]