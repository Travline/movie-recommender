name := "movie-recommender"
version := "1.0"
scalaVersion := "2.13.12"

// Para permitir compilar como un solo JAR ejecutable independiente
assembly / assemblyMergeStrategy := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x => MergeStrategy.first
}