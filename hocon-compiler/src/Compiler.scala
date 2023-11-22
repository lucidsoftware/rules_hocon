package ruleshocon

import java.io.{File, FileWriter}
import scala.io.Source
import scala.util.control.NonFatal
import scala.util.Using
import com.typesafe.config._
import org.rogach.scallop._

object Compiler {
  class CommandOpts(arguments: Seq[String]) extends ScallopConf(arguments, List("hocon-compiler")) {
    banner("Hocon compiler and flattener")
    val base = opt[File]()
    val output = opt[File](required = true)
    val include = opt[List[File]](default = Some(Nil))
    val resolveLists = opt[List[File]]("env-key-lists", default = Some(Nil)).map { files =>
      new ResolveLists(files.iterator.map { file =>
        file.getName -> readResolveList(file)
      }.toMap)
    }
    val optionalInclude = opt[List[String]](short = 'D', default = Some(Nil)).map(_.toSet)
    val header = opt[String](default = Some(""))
    val warnings = opt[Boolean](default = Some(false))
    val allowMissing = opt[Boolean](default = Some(false))
    val includeComments = toggle("comments", default = Some(true), noshort = true)
    val doResolve = toggle("resolve", default = Some(true), noshort = true)
    val src = trailArg[File]()

    verify()
  }

  final def main(args: Array[String]): Unit = {
    val opts = new CommandOpts(args.toIndexedSeq)

    try {
      val configParser = new ConfigParser(opts.include(), opts.optionalInclude())
      val baseConfig = opts.base.toOption.map(configParser.parse)
      val mainConfig = configParser.parse(opts.src())
      val merged =
        baseConfig.map(base => ConfigMerger.mergeOverrides(mainConfig, base, opts.warnings())).getOrElse(mainConfig)

      val resolved = resolve(merged, opts.resolveLists(), opts.allowMissing())

      val finalConfig = if (opts.doResolve()) {
        resolved
      } else {
        merged
      }

      val renderOptions = ConfigRenderOptions
        .defaults()
        .setOriginComments(false)
        .setComments(opts.includeComments())

      writeConfig(finalConfig, renderOptions, opts.output(), opts.header())
    } catch {
      case NonFatal(e) =>
        printError(e)
        System.exit(1)
    }
  }

  private def resolve(conf: Config, resolveLists: ResolveLists, allowMissing: Boolean): Config = {
    val resolver = new PathCheckResolver(resolveLists.validKeys.toSet)
    val resolveOptions = ConfigResolveOptions
      .defaults()
      .appendResolver(resolver)
      .setAllowUnresolved(true)
      .setUseSystemEnvironment(false)
    // Resolve to make sure any references refer to something defined either
    // at compile time (in the conf files) or runtime (specified by the resolve lists)
    //
    // This will also simplify any references to other config that can be resolved, producing
    // a simpler configuration output (if the result is used).
    val resolved = conf.resolve(resolveOptions)

    if (resolver.hasMissingPaths && !allowMissing) {
      if (resolveLists.isEmpty) {
        printError(s"Unresolvable keys: ${resolver.missingPaths.mkString(", ")}")
      } else {
        for ((role, keys) <- resolveLists.missingKeysPerList(resolver.missingPaths)) {
          printError(s"Role ${role} does not have the following keys: ${keys.mkString(", ")}")
        }
      }
      System.exit(1)
    }
    resolved
  }

  private val errorPrefix = "\u001b[31mERROR:\u001b[0m "
  private def printError(s: String): Unit = {
    System.err.println(errorPrefix + s)
  }

  private def printError(t: Throwable): Unit = {
    System.err.print(errorPrefix)
    t.printStackTrace()
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
    builder.result()
  }

  private def writeConfig(conf: Config, renderOpts: ConfigRenderOptions, path: File, header: String): Unit = {
    Using.resource(new FileWriter(path)) { writer =>
      writer.write(header)
      writer.write("\n")
      writer.write(conf.root.render(renderOpts))
    }
  }
}
