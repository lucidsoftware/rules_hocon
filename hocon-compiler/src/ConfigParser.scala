package ruleshocon

import com.typesafe.config._
import java.io.File
import java.nio.file.{Files, Path, Paths}

class ConfigParser(paths: Traversable[File] = Nil, allowedMissing: Set[String]) {
  private val options = ConfigParseOptions.defaults()
    .setAllowMissing(false)
    .setIncluder(new PathIncluder(paths, allowedMissing))

  def parse(file: File): Config = {
    ConfigFactory.parseFile(file, options)
  }
}

private class PathIncluder(paths: Traversable[File], allowedMissing: Set[String]) extends ConfigIncluder
  with ConfigIncluderFile {
  private val nameMap: Map[String, File] = paths.map { file =>
    file.getName -> file
  }.toMap

  def include(context: ConfigIncludeContext, what: String): ConfigObject = {
    getFile(what) match {
      case Some(file) => ConfigFactory.parseFile(file, context.parseOptions).root
      case None => if (what.contains('/')) {
        val rel = context.relativeTo(what)
        if (findFile(Paths.get(rel.origin.url.toURI)).isDefined) {
          rel.parse(context.parseOptions)
        } else {
          throw new ConfigException.Missing(what)
        }
      } else if (allowedMissing.contains(what)) {
        emptyConfig
      } else {
        throw new ConfigException.Missing(what)
      }
    }
  }

  def includeFile(context: ConfigIncludeContext, what: File): ConfigObject = {
    findFile(what.toPath) match {
      case Some(f) => ConfigFactory.parseFile(f, context.parseOptions).root
      case None => if (allowedMissing.contains(what.toString)) {
        emptyConfig
      } else {
        throw new ConfigException.Missing(what.toString)
      }
    }
  }

  // Just ignore the fallback
  def withFallback(fallback: ConfigIncluder): ConfigIncluder = this

  private def getFile(what: String): Option[File] = if (what.endsWith(".conf")) {
    nameMap.get(what)
  } else {
    nameMap.get(what + ".conf")
  }

  private def findFile(what: Path): Option[File] = nameMap.valuesIterator.find({ f =>
    Files.isSameFile(f.toPath, what)
  })

  private val emptyConfig = ConfigValueFactory.fromMap(new java.util.TreeMap)
}
