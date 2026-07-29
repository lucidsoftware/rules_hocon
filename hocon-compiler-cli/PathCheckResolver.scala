package ruleshocon

import com.typesafe.config.{ConfigResolver, ConfigValue}
import scala.collection.mutable

class PathCheckResolver(validKeys: Set[String]) extends ConfigResolver {
  import PathCheckResolver._

  private val _missingPaths: mutable.Set[String] = mutable.Set.empty

  def missingPaths = _missingPaths.toSet

  def hasMissingPaths: Boolean = _missingPaths.nonEmpty

  def lookup(path: String): ConfigValue = {
    if (!validKeys.contains(path)) {
      _missingPaths += path
    }
    null
  }

  def withFallback(fallback: ConfigResolver): ConfigResolver = new WithFallback(validKeys, fallback, _missingPaths)
}

object PathCheckResolver {
  private class WithFallback(validKeys: Set[String], fallback: ConfigResolver, missingPaths: mutable.Set[String])
      extends ConfigResolver {
    def lookup(path: String): ConfigValue = {
      if (validKeys.contains(path)) {
        null
      } else {
        val result = fallback.lookup(path)
        if (result == null) {
          missingPaths += path
        }
        result
      }
    }

    def withFallback(newFallback: ConfigResolver): ConfigResolver = {
      if (newFallback == fallback) {
        this
      } else {
        new WithFallback(validKeys, fallback.withFallback(newFallback), missingPaths)
      }
    }
  }

}
