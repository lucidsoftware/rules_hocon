package ruleshocon

import java.io.{File, FileWriter}
import scala.io.Source
import scala.util.control.NonFatal
import com.typesafe.config._

object Compiler {
  case class CommandOpts(
    src: File,
    output: File,
    base: Option[File] = None,
    includes: Seq[File] = Seq.empty,
    resolveLists: ResolveLists = ResolveLists.empty,
    optionalIncludes: Set[String] = Set.empty,
    header: String = ""
  )


  private val parser = new scopt.OptionParser[CommandOpts]("hocon-compiler") {
    head("Hocon compiler and flattener", "0.1")
    arg[File]("<output>").required().action { (value, config) =>
      config.copy(output = value)
    }
    arg[File]("<src>").required().action { (value, config) =>
      config.copy(src = value)
    }

    opt[File]('b', "base").maxOccurs(1).optional().action { (value, config) =>
      config.copy(base = Some(value))
    }

    opt[Seq[File]]('i', "include").valueName("<conf_include>").unbounded().action { (value, config) =>
      config.copy(includes = config.includes ++ value)
    }.text("Files to add to the include path for config generation")

    opt[Seq[File]]('m', "env-key-list").unbounded().action { (value, config) =>
      val resolveLists = value.map { file =>
        file.getName -> readResolveList(file)
      }
      config.copy(resolveLists = config.resolveLists ++ resolveLists)
    }

    opt[Seq[String]]('D', "optional-include").unbounded().action { (value, config) =>
      config.copy(optionalIncludes = config.optionalIncludes ++ value)
    }

    opt[String]('H', "header").maxOccurs(1).optional().action { (value, config) =>
      config.copy(header = value)
    }
  }

  private val renderOptions = ConfigRenderOptions.defaults()
    .setOriginComments(false)
    .setJson(false)

  final def main(args: Array[String]): Unit = {
    val opts = parser.parse(args, CommandOpts(null, null)).getOrElse {
      return System.exit(1)
    }

    try {
      val configParser = new ConfigParser(opts.includes, opts.optionalIncludes)
      val baseConfig = opts.base.map(configParser.parse)
      val mainConfig = configParser.parse(opts.src)
      val merged = baseConfig.map(base => ConfigMerger.mergeOverrides(mainConfig, base)).getOrElse(mainConfig)

      checkResolution(merged, opts.resolveLists)

      writeConfig(merged, opts.output, opts.header)
    } catch {
      case NonFatal(e) =>
        printError(e.toString)
        System.exit(1)
    }
  }

  private def checkResolution(conf: Config, resolveLists: ResolveLists): Unit = {
    val resolver = new PathCheckResolver(resolveLists.validKeys)
    val resolveOptions = ConfigResolveOptions.defaults()
      .appendResolver(resolver)
      .setAllowUnresolved(true)
      .setUseSystemEnvironment(false)
    // Resolve to make sure any references refer to something defined either
    // at compile time (in the conf files) or runtime (specified by the resolve lists)
    //
    // NB: don't actually use the resolved result because it
    // can produce invalid output when there are unresolved values
    // while merging fallbacks
    conf.resolve(resolveOptions)

    if (resolver.hasMissingPaths) {
      if (resolveLists.isEmpty) {
        printError(s"Unresolvable keys: ${resolver.missingPaths.mkString(", ")}")
      } else {
        for ((role, keys) <- resolveLists.missingKeysPerList(resolver.missingPaths)) {
             printError(s"Role ${role} does not have the following keys: ${keys.mkString(", ")}")
        }
      }
      System.exit(1)
    }
  }

  private def printError(s: String) {
    System.err.println("\u001b[31mERROR:\u001b[0m " + s)
  }

  private def readResolveList(file: File): Set[String] = {
    val builder = Set.newBuilder[String]
    val source = Source.fromFile(file)
    try {
      for (line <- source.getLines()) {
        builder += line
      }
    } finally {
      source.close()
    }
    builder.result
  }

  private def writeConfig(conf: Config, path: File, header: String) {
    val writer = new FileWriter(path)
    try {
      writer.write(header)
      writer.write("\n")
      writer.write(conf.root.render(renderOptions))
    } finally {
      writer.close()
    }
  }
}
