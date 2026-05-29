import os
import json
import subprocess
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI(title="Polyglot Movie Recommender API")

origins = [
    "http://localhost:5173",
    "http://localhost:3000",
    "http://localhost:8000",
    "https://movie-recommender-no03.onrender.com",
    "https://vga-recommender.vercel.app"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class RecommendationRequest(BaseModel):
    generos: List[str]
    favoritas: List[str]

@app.post("/api/recomendar")
def recomendar_peliculas(req: RecommendationRequest):
    if not req.favoritas and not req.generos:
        raise HTTPException(status_code=400, detail="Debes proveer al menos un género o una película favorita.")

    generos_pl = "[" + ",".join([f"'{g.lower().strip()}'" for g in req.generos]) + "]" if req.generos else "[]"
    favoritas_pl = "[" + ",".join([f"'{f.lower().strip()}'" for f in req.favoritas]) + "]" if req.favoritas else "[]"

    query = f"recomendar({favoritas_pl}, {generos_pl}, X), forall(member(P, X), writeln(P)), halt."
    prolog_file = "/app/prolog/knowledge_base.pl"

    try:
        prolog_process = subprocess.run(
            ["swipl", "-q", "-s", prolog_file, "-g", query],
            capture_output=True, text=True, check=True
        )
        
        output_prolog = prolog_process.stdout.strip()
        
        candidatas = [line.strip() for line in output_prolog.splitlines() if line.strip()]
        
    except Exception as e:
         raise HTTPException(status_code=500, detail=f"Error ejecutando Prolog: {str(e)}")

    if not candidatas:
        return []

    scala_jar = "/app/scala/target/scala-2.13/movie-recommender-assembly-1.0.jar"
    csv_path = "/app/pelis.csv"
    candidatas_json_str = json.dumps(candidatas)

    try:
        scala_process = subprocess.run(
            ["java", "-jar", scala_jar, csv_path, candidatas_json_str],
            capture_output=True, text=True, check=True
        )
        resultado_final = json.loads(scala_process.stdout.strip())
        return resultado_final
    except Exception as e:
         raise HTTPException(status_code=500, detail=f"Error ejecutando Scala: {str(e)}")