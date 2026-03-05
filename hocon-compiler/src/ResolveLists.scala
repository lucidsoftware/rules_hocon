package ruleshocon

/**
 * A set of named lists of keys that are allowed to be unresolved during compilation.
 *
 * Typically, these are lists of keys that are defined at runtime, multiple lists
 * are allowed in the case that there are different environments with different
 * keys that are set, and the compiler will fail unless keys are available for
 * *all* environments.
 *
 * Each list may contain either:
 *   - Legacy flat keys: e.g. "secretBag.jwt_default_rsa_public_key_pem"
 *   - SSM path patterns: e.g. "/shared/jwt_default_rsa_public_key_pem" (exact)
 *                        or   "/print/" (prefix wildcard — any key under /print/)
 */
class ResolveLists(roles: Map[String, Set[String]]) {
  def validKeys: Set[String] = roles.valuesIterator.reduceOption(_ & _).getOrElse(Set.empty)

  def isEmpty: Boolean = roles.isEmpty

  /**
   * Check if a HOCON substitution path is valid for ALL roles.
   * Supports both legacy flat-key format and new SSM path pattern format.
   */
  def isValid(path: String): Boolean = {
    if (roles.isEmpty) true
    else roles.values.forall(patterns => isValidForPatterns(path, patterns))
  }

  /**
   * Given a set of keys, return a mapping from list name to the set of those keys that
   * are missing for that list.
   */
  def missingKeysPerList(keys: Set[String]): Map[String, Set[String]] = {
    roles.view.mapValues { patterns =>
      keys.filterNot(key => isValidForPatterns(key, patterns))
    }.filter(_._2.nonEmpty).toMap
  }

  def +(pair: (String, Set[String])): ResolveLists = {
    new ResolveLists(roles + pair)
  }

  private val secretBagPrefix = "secretBag."

  /**
   * Check whether a single HOCON substitution path is covered by the given set of patterns.
   *
   * Pattern formats:
   *   - Plain string (no leading /): legacy exact match, e.g. "secretBag.foo"
   *   - SSM prefix wildcard (starts with / and ends with /): e.g. "/print/"
   *     Any secretBag key is accepted when a prefix wildcard is present for that role,
   *     since we cannot enumerate SSM keys at build time.
   *   - Exact SSM path (starts with / but no trailing /): e.g. "/shared/jwt_rsa_pub"
   *     The leading namespace component is stripped and the rest is compared as a
   *     dot-separated key, e.g. /shared/foo/bar -> foo.bar
   *
   * If the pattern set contains no SSM path entries (no entries starting with "/"),
   * the role is treated as unconstrained and all secretBag keys are accepted.
   * This handles roles not yet present in the mapping file.
   */
  private def isValidForPatterns(path: String, patterns: Set[String]): Boolean = {
    // Legacy exact match (old flat-key format like "secretBag.foo")
    if (patterns.contains(path)) return true

    // Only apply SSM pattern matching to secretBag.* paths.
    // Non-secretBag substitutions (env vars, plain config keys) pass through.
    if (!path.startsWith(secretBagPrefix)) return true

    // If no SSM-style patterns present, role is not yet in the mapping file — unconstrained.
    val ssmPatterns = patterns.filter(_.startsWith("/"))
    if (ssmPatterns.isEmpty) return true

    val key = path.drop(secretBagPrefix.length)

    ssmPatterns.exists { pattern =>
      if (pattern.endsWith("/")) {
        // Prefix wildcard: accept any secretBag key for this namespace.
        true
      } else {
        // Exact SSM path: strip the leading namespace component and compare.
        //   /shared/jwt_default_rsa_public_key_pem  -> jwt_default_rsa_public_key_pem
        //   /shared/lucid_service_default/acceptableSecrets -> lucid_service_default.acceptableSecrets
        val parts = pattern.stripPrefix("/").split("/", -1)
        if (parts.length >= 2) {
          val flatKey = parts.tail.mkString(".")
          key == flatKey
        } else false
      }
    }
  }
}
