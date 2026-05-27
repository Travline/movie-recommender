import scala.io.Source

object Recommender {
  
  case class Movie(nombre: String, generos: String, director: String, puntuacion: Double, linkPortada: String)

  def main(args: Array[String]): Unit = {
    // Si no se pasan los argumentos mínimos requeridos (ruta csv y JSON de candidatas)
    if (args.length < 2) {
      println("[]")
      sys.exit(0)
    }

    val csvPath = args(0)
    val candidatasRaw = args(1)
    
    // Limpieza funcional del String que simula un JSON Array crudo: ["peli 1", "peli 2"]
    val candidatas = candidatasRaw
      .replace("[", "")
      .replace("]", "")
      .replace("\"", "")
      .split(",")
      .map(_.trim.toLowerCase)
      .toSet

    // Lectura funcional del archivo CSV lína por línea
    val lineas = Source.fromFile(csvPath)(io.Codec.UTF8).getLines().drop(1).toList

    val peliculas: List[Movie] = lineas.flatMap { linea =>
      // Expresión regular para separar por comas respetando strings estructurados sencillos
      val tokens = linea.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)")
      if (tokens.length >= 5) {
        Some(Movie(
          nombre = tokens(0).trim,
          generos = tokens(1).trim,
          director = tokens(2).trim,
          puntuacion = tokens(3).trim.toDoubleOption.getOrElse(0.0),
          linkPortada = tokens(4).trim
        ))
      } else None
    }

    // Filtrado cruzando la data con las seleccionadas por Prolog (ambos llevados a minúsculas)
    val recomendadasOrdenadas = peliculas
      .filter(m => candidatas.contains(m.nombre.trim.toLowerCase))
      .sortBy(_.puntuacion)(Ordering[Double].reverse)

    // Construcción limpia y funcional del String JSON de salida para transferir de vuelta a Python
    val jsonResult = recomendadasOrdenadas.map { m =>
      s"""{
         |  "nombre": "${m.nombre}",
         |  "generos": "${m.generos}",
         |  "director": "${m.director}",
         |  "puntuacion": ${m.puntuacion},
         |  "link_portada": "${m.linkPortada}"
         |}""".stripMargin
    }.mkString("[", ",", "]")

    // Retornamos el resultado final por consola (capturado por subprocess en Python)
    println(jsonResult)
  }
}