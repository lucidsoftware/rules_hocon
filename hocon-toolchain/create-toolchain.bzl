load(":hocon-toolchain.bzl", "hocon_toolchain")

def create_hocon_toolchain(name, hocon_compiler, jvm_flags = []):
    """Defines and configures a Hocon toolchain.

    Args:
        name: Name of the generated `toolchain` target. Register it in MODULE.bazel with `register_toolchains`.
        hocon_compiler: Label of the executable Hocon compiler to use.
        jvm_flags: JVM options passed to the compiler at JVM startup.
    """
    toolchain_name = "{}-toolchain".format(name)
    hocon_toolchain(
        name = toolchain_name,
        hocon_compiler = hocon_compiler,
        jvm_flags = jvm_flags,
    )

    native.toolchain(
        name = name,
        toolchain = toolchain_name,
        toolchain_type = "@rules_hocon//hocon-toolchain:toolchain_type",
    )
