import scala.io.Source

object Recommender {
  
  case class Movie(nombre: String, generos: String, director: String, puntuacion: Double, linkPortada: String)

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      println("[]")
      sys.exit(0)
    }

    val csvPath = args(0)
    val candidatasRaw = args(1)
    
    val candidatas = candidatasRaw
      .replace("[", "")
      .replace("]", "")
      .replace("\"", "")
      .split(",")
      .map(_.trim.toLowerCase)
      .toSet

    val lineas = Source.fromFile(csvPath)(io.Codec.UTF8).getLines().drop(1).toList

    val peliculas: List[Movie] = lineas.flatMap { linea =>
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

    val recomendadasOrdenadas = peliculas
      .filter(m => candidatas.contains(m.nombre.trim.toLowerCase))
      .sortBy(_.puntuacion)(Ordering[Double].reverse)

    val jsonResult = recomendadasOrdenadas.map { m =>
      s"""{
         |  "nombre": "${m.nombre}",
         |  "generos": "${m.generos}",
         |  "director": "${m.director}",
         |  "puntuacion": ${m.puntuacion},
         |  "link_portada": "${m.linkPortada}"
         |}""".stripMargin
    }.mkString("[", ",", "]")

    println(jsonResult)
  }
}