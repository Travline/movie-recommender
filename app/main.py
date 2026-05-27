import os
import json
import subprocess
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI(title="Polyglot Movie Recommender API")

class RecommendationRequest(BaseModel):
    generos: List[str]
    favoritas: List[str]

@app.post("/api/recomendar")
def recomendar_peliculas(req: RecommendationRequest):
    if not req.favoritas and not req.generos:
        raise HTTPException(status_code=400, detail="Debes proveer al menos un género o una película favorita.")

    # 1. Preparar argumentos para Prolog
    # Formateamos las listas para que Prolog las entienda como listas de átomos: [item1, item2]
    generos_pl = "[" + "," + "".join([f"'{g.lower().strip()}'" for g in req.generos]) + "]" if req.generos else "[]"
    favoritas_pl = "[" + "," + "".join([f"'{f.lower().strip()}'" for f in req.favoritas]) + "]" if req.favoritas else "[]"

    # Consulta Prolog que unifica la variable 'X' con las recomendaciones
    query = f"recomendar({favoritas_pl}, {generos_pl}, X), writeln(X), halt."
    prolog_file = "/app/prolog/knowledge_base.pl"

    try:
        # Ejecutar SWI-Prolog por CLI
        prolog_process = subprocess.run(
            ["swipl", "-q", "-s", prolog_file, "-g", query],
            capture_output=True, text=True, check=True
        )
        # La salida de Prolog será un formato tipo ["Peli 1", "Peli 2"]
        output_prolog = prolog_process.stdout.strip()
        
        # Reemplazar comillas simples por dobles para parsearlo como JSON Array en Python/Scala
        output_prolog = output_prolog.replace("'", '"')
        candidatas = json.loads(output_prolog) if output_prolog else []
    except Exception as e:
         raise HTTPException(status_code=500, detail=f"Error ejecutando Prolog: {str(e)}")

    if not candidatas:
        return []

    # 2. Pasar las candidatas a Scala para ordenamiento funcional
    scala_jar = "/app/scala/target/scala-2.13/movie-recommender-assembly-1.0.jar"
    csv_path = "/app/pelis.csv"
    candidatas_json_str = json.dumps(candidatas)

    try:
        # Ejecutamos el archivo JAR compilado de Scala pasándole el CSV y las candidatas
        scala_process = subprocess.run(
            ["java", "-jar", scala_jar, csv_path, candidatas_json_str],
            capture_output=True, text=True, check=True
        )
        # Scala nos devolverá un String en JSON plano con la data estructurada y ordenada
        resultado_final = json.loads(scala_process.stdout.strip())
        return resultado_final
    except Exception as e:
         raise HTTPException(status_code=500, detail=f"Error ejecutando Scala: {str(e)}")