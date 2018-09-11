package ruleshocon

/**
 * A set of named lists of keys that are allowed to be unresolved during compilation.
 *
 * Typically, these are lists of keys that are defined at runtime, multiple lists
 * are allowed in the case that there are different environments with different
 * keys that are set, and the compiler will fail unless keys are available for
 * *all* environments.
 */
class ResolveLists(roles: Map[String, Set[String]]) {
  def validKeys: Set[String] = roles.valuesIterator.reduceOption(_ & _).getOrElse(Set.empty)

  def isEmpty: Boolean = roles.isEmpty

  /**
   * Given a set of keys, return a mapping from list name to the set of those keys that
   * are missing for that list.
   */
  def missingKeysPerList(keys: Set[String]): Map[String, Set[String]] = {
    roles.mapValues(keys.diff).filter(_._2.nonEmpty)
  }

  def +(pair: (String, Set[String])): ResolveLists = {
    new ResolveLists(roles + pair)
  }
}
