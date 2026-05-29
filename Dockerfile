FROM hseeberger/scala-sbt:8u312_1.6.2_2.13.8 AS scala-builder
WORKDIR /build
COPY scala /build
RUN sbt assembly

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    swi-prolog \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3.11 /usr/bin/python

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY pelis.csv .
COPY app/ ./app
COPY prolog/ ./prolog

COPY --from=scala-builder /build/target/scala-2.13/movie-recommender-assembly-1.0.jar ./scala/target/scala-2.13/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]