import scala.io.Source
import scala.util.parsing.json.JSON // O manipulación nativa de strings para evitar dependencias pesadas

object Recommender {
  
  case class Movie(nombre: String, generos: String, director: String, puntuacion: Double, linkPortada: String)

  def main(args: Array[args.type]): Unit = {
    if (args.length < 2) {
      println("[]")
      sys.exit(1)
    }

    val csvPath = args(0)
    // Recibimos un string JSON crudo de Python: ["peli 1", "peli 2"]
    val candidatasRaw = args(1)
    
    // Limpieza artesanal y funcional del JSON Array crudo de entrada
    val candidatas = candidatasRaw
      .replace("[", "").replace("]", "").replace("\"", "")
      .split(",").map(_.trim.toLowerCase).toSet

    // Lectura funcional del archivo CSV
    val lineas = Source.fromFile(csvPath)(io.Codec.UTF8).getLines().drop(1).toList

    val peliculas: List[Movie] = lineas.flatMap { linea =>
      // Expresión regular simple para separar por comas respetando contenidos básicos
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

    // Filtrado funcional cruzando con lo enviado por Prolog y ordenamiento por Ranking (Puntuación Descendente)
    val recomendadasOrdenadas = peliculas
      .filter(m => candidatas.contains(m.nombre.toLowerCase))
      .sortBy(_.puntuacion)(Ordering[Double].reverse)

    // Construcción manual de un string JSON para evitar añadir librerías externas en el JAR
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