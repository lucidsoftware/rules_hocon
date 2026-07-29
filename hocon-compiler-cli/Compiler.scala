package ruleshocon

import com.typesafe.config.*
import higherkindness.rules_scala.common.error.AnnexWorkerError
import higherkindness.rules_scala.common.interrupt.InterruptUtil
import higherkindness.rules_scala.common.sandbox.PathResolver
import higherkindness.rules_scala.common.worker.{WorkTask, WorkerMain}
import java.io.{File, FileWriter, PrintStream}
import java.nio.file.{Files, Paths}
import org.rogach.scallop.*
import org.rogach.scallop.exceptions.*
import scala.jdk.CollectionConverters.*
import scala.util.control.NonFatal
import scala.util.Using

object Compiler extends WorkerMain[Unit] {
  class CommandOpts(
    arguments: Seq[String],
    pathResolver: PathResolver,
    out: PrintStream,
  ) extends ScallopConf(arguments, List("hocon-compiler")) {
    banner("Hocon compiler and flattener")

    val base = opt[File]().map(pathResolver.resolve)
    val output = opt[File](required = true).map(pathResolver.resolve)
    val include = opt[List[File]](default = Some(Nil)).map(_.map(pathResolver.resolve))
    val envKeyLists = opt[List[File]](
      "env-key-lists",
      default = Some(Nil),
    ).map(_.map(pathResolver.resolve))
    val optionalInclude = opt[List[String]](short = 'D', default = Some(Nil)).map(_.toSet)
    val headerFile = opt[File]("header", short = 'H').map(pathResolver.resolve)
    val warnings = opt[Boolean](default = Some(false))
    val allowMissing = opt[Boolean](default = Some(false))
    val includeComments = toggle("comments", default = Some(true), noshort = true)
    val doResolve = toggle("resolve", default = Some(false), noshort = true)
    val json = toggle("json", default = Some(false), noshort = true)
    val src = trailArg[File]().map(pathResolver.resolve)

    override def onError(e: Throwable): Unit = e match {
      case Help(subcommand) =>
        // `Help`'s field is the subcommand name, not the help text. An empty name means the
        // top-level command, so render the full help from the builder (as Scallop's default does).
        val helpText =
          if (subcommand.isEmpty) builder.getFullHelpString()
          else builder.findSubbuilder(subcommand).get.getFullHelpString()
        out.println(helpText)
        throw new AnnexWorkerError(0)

      case Version =>
        out.println(builder.vers.getOrElse("Unknown version"))
        throw new AnnexWorkerError(0)

      case e: ScallopException =>
        throw new AnnexWorkerError(1, "Encountered ScallopException", e)

      case _ =>
        throw new AnnexWorkerError(1, "Unknown Scallop error", e)
    }

    verify()

    lazy val header = headerFile.map(headerFile => Files.readString(headerFile.toPath())).getOrElse("")
  }

  override def init(args: Option[Array[String]]): Unit = ()

  protected def work(task: WorkTask[Unit]): Unit = {
    // WorkerMain does not expand param files, so we do it here.
    val finalArgs = task.args.toList.flatMap {
      case arg if arg.startsWith("@") => Files.readAllLines(Paths.get(arg.tail)).asScala
      case arg                        => List(arg)
    }

    val opts = new CommandOpts(finalArgs, PathResolver.forPersistentWorker(task.workDir), task.output)

    try {
      InterruptUtil.throwIfInterrupted(task.isCancelled)

      val includes = opts.include()
      val configParser = new ConfigParser(includes, opts.optionalInclude())
      val baseConfig = opts.base.toOption.map(configParser.parse)
      val mainConfig = configParser.parse(opts.src())

      InterruptUtil.throwIfInterrupted(task.isCancelled)

      val merged =
        baseConfig
          .map(base => ConfigMerger.mergeOverrides(mainConfig, base, opts.warnings(), task.output))
          .getOrElse(mainConfig)

      InterruptUtil.throwIfInterrupted(task.isCancelled)

      val resolveLists = new ResolveLists(
        opts
          .envKeyLists()
          .iterator
          .map { file =>
            file.getName -> readResolveList(file)
          }
          .toMap,
      )

      val resolved = resolve(merged, resolveLists, opts.allowMissing(), task.output)

      InterruptUtil.throwIfInterrupted(task.isCancelled)

      val finalConfig = if (opts.doResolve()) {
        resolved
      } else {
        merged
      }

      val renderOptions = ConfigRenderOptions
        .defaults()
        .setOriginComments(false)
        .setJson(opts.json())
        .setComments(opts.includeComments())

      writeConfig(finalConfig, renderOptions, opts.output(), opts.header)
    } catch {
      case NonFatal(e) =>
        printError(e, task.output)
        throw new AnnexWorkerError(1)
    }
  }

  private def resolve(conf: Config, resolveLists: ResolveLists, allowMissing: Boolean, out: PrintStream): Config = {
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
        printError(s"Unresolvable keys: ${resolver.missingPaths.mkString(", ")}", out)
      } else {
        for ((role, keys) <- resolveLists.missingKeysPerList(resolver.missingPaths)) {
          printError(s"Role ${role} does not have the following keys: ${keys.mkString(", ")}", out)
        }
      }
      throw new AnnexWorkerError(1)
    }
    resolved
  }

  private val errorPrefix = "\u001b[31mERROR:\u001b[0m "
  private def printError(s: String, out: PrintStream): Unit = {
    out.println(errorPrefix + s)
  }

  private def printError(t: Throwable, out: PrintStream): Unit = {
    out.print(errorPrefix)
    t.printStackTrace(out)
  }

  private def readResolveList(file: File): Set[String] = {
    Using.resource(scala.io.Source.fromFile(file))(_.getLines().toSet)
  }

  private def writeConfig(conf: Config, renderOpts: ConfigRenderOptions, path: File, header: String): Unit = {
    Using.resource(new FileWriter(path)) { writer =>
      writer.write(header)
      writer.write("\n")
      writer.write(conf.root.render(renderOpts))
    }
  }
}
