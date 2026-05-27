# Estructura multi-stage para compilar Scala sin ensuciar la imagen final
FROM hseeberger/scala-sbt:8u312_1.6.2_2.13.8 AS scala-builder
WORKDIR /build
COPY scala /build
RUN sbt assembly

# Imagen Base Final basada en Python
FROM python:3.11-slim

# Instalar dependencias del sistema: SWI-Prolog y Java Runtime para Scala
RUN apt-get update && apt-get install -y \
    swi-prolog \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar dependencias de Python e instalar
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar los recursos del proyecto
COPY pelis.csv .
COPY app/ ./app
COPY prolog/ ./prolog

# Copiar el JAR compilado desde la primera etapa de construcción
COPY --from=scala-builder /build/target/scala-2.13/movie-recommender-assembly-1.0.jar ./scala/target/scala-2.13/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]