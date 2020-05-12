package ruleshocon

import com.typesafe.config._
import scala.annotation.tailrec
import scala.collection.JavaConverters._

object ConfigMerger {
  /**
   * Merge overrides with base config
   */
  def mergeOverrides(overrides: Config, base: Config, warnings: Boolean): Config = {
    if (warnings) {
      val extraKeys = addedKeys(overrides, base)
      if (extraKeys.nonEmpty) {
        System.err.println(s"\u001b[31mWARN:\u001b[0m ${overrides.origin.filename} has config keys not in ${base.origin.filename}:\n\t${extraKeys.mkString("\n\t")}")
      }
    }
    overrides.withFallback(base)
  }

  /**
   * Get a set of keys that are in `overrides` but not in `parent`.
   */
  private def addedKeys(overrides: Config, parent: Config): Set[String] = {
    overrides.entrySet.asScala.flatMap { entry =>
      val path = entry.getKey
      if (safeHasPath(parent, path)) {
        None
      } else {
        Some(path)
      }
    }.toSet
  }

  private def safeHasPath(conf: Config, path: String): Boolean = {
    @tailrec
    def impl(current: ConfigValue, path: Seq[String]): Boolean = {
      if (path.isEmpty) {
        true
      } else {
        current match {
          case obj: ConfigObject => if (obj.containsKey(path.head)) {
            impl(obj.get(path.head), path.tail)
          } else {
            false
          }
          case _ => false
        }
      }
    }

    impl(conf.root, ConfigUtil.splitPath(path).asScala)
  }
}
