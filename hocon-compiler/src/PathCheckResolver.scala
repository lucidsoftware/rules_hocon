package ruleshocon

import com.typesafe.config.{ConfigResolver, ConfigValue}
import scala.collection.mutable

class PathCheckResolver(resolveLists: ResolveLists) extends ConfigResolver {
  import PathCheckResolver._

  private val _missingPaths: mutable.Set[String] = mutable.Set.empty

  def missingPaths = _missingPaths.toSet

  def hasMissingPaths: Boolean = _missingPaths.nonEmpty

  def lookup(path: String): ConfigValue = {
    if (!resolveLists.isValid(path)) {
      _missingPaths += path
    }
    null
  }

  def withFallback(fallback: ConfigResolver): ConfigResolver = new WithFallback(resolveLists, fallback, _missingPaths)
}

object PathCheckResolver {
  private class WithFallback(resolveLists: ResolveLists, fallback: ConfigResolver, missingPaths: mutable.Set[String]) extends ConfigResolver {
    def lookup(path: String): ConfigValue = {
      if (resolveLists.isValid(path)) {
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
        new WithFallback(resolveLists, fallback.withFallback(newFallback), missingPaths)
      }
    }
  }

}
