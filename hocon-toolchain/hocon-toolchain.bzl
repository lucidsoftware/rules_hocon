def _hocon_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        hocon_compiler = ctx.attr.hocon_compiler,
        jvm_flags = ctx.attr.jvm_flags,
    )
    return [toolchain_info]

hocon_toolchain = rule(
    implementation = _hocon_toolchain_impl,
    attrs = {
        "hocon_compiler": attr.label(
            mandatory = True,
            cfg = "exec",
            executable = True,
            doc = "Tool used to compile HOCON configuration files",
        ),
        "jvm_flags": attr.string_list(
            doc = "JVM options to pass when invoking the HOCON compiler.",
        ),
    },
    doc = "Defines a toolchain for compiling HOCON configuration files based on a HOCON compiler",
    provides = [platform_common.ToolchainInfo],
)
