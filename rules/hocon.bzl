"""Lucid Hocon compilation rules

Bazel rules for compiling multiple HOCON source files into a flattend HOCON artifact.

In addition to checking syntax and flattening the configuration files, it also verifies that
any references (`${}` syntax) either refer to internal config, or keys from a whitelist of
config that will provided at runtime.

[HOCON](https://github.com/lightbend/config)

"""
PROPAGATABLE_TAGS = ["no-remote", "no-cache", "no-sandbox", "no-remote-exec", "no-remote-cache"]

def resolve_execution_reqs(ctx, base_exec_reqs):
    exec_reqs = {}
    for tag in ctx.attr.tags:
        if tag in PROPAGATABLE_TAGS:
            exec_reqs.update({tag: "1"})
    exec_reqs.update(base_exec_reqs)
    return exec_reqs

def _hocon_library_impl(ctx):
    all_inputs = [ctx.file.src]
    args = ctx.actions.args()
    args.add("-o", ctx.outputs.out)
    if ctx.file.base:
        args.add("-b", ctx.file.base)
        all_inputs.append(ctx.file.base)
    args.add_all("-i", ctx.files.deps, omit_if_empty = True)
    all_inputs.extend(ctx.files.deps)

    args.add_all("-e", ctx.files.env_key_lists, omit_if_empty = True)
    all_inputs.extend(ctx.files.env_key_lists)

    if ctx.attr.header:
        args.add("-h", ctx.attr.header)

    args.add_all("-D", ctx.attr.optional_includes, omit_if_empty = True, uniquify = True)

    if ctx.attr.warnings:
        args.add("--warnings")
    args.add(ctx.file.src)

    args.use_param_file("@%s")

    ctx.actions.run(
        executable = ctx.executable._hocon_compiler,
        progress_message = "Compiling hocon config (%s)" % ctx.label.name,
        execution_requirements = resolve_execution_reqs(ctx, {}),
        inputs = all_inputs,
        arguments = [args],
        outputs = [ctx.outputs.out],
    )

hocon_library = rule(
    implementation = _hocon_library_impl,
    attrs = {
        "src": attr.label(
            doc = "The source file for the hocon library",
            allow_single_file = [".conf"],
            mandatory = True,
        ),
        "base": attr.label(
            doc = "Optional base config to use. Generally, this should be the output from another hocon_library",
            allow_single_file = [".conf"],
            mandatory = False,
        ),
        "deps": attr.label_list(
            doc = "List of config files that the source file includes",
            allow_empty = True,
            allow_files = [".conf", ".json"],
            default = [],
        ),
        "optional_includes": attr.string_list(
            doc = "Names for files to include that may or may not be available.",
            allow_empty = True,
            default = [],
        ),
        "env_key_lists": attr.label_list(
            doc = """List of files containging lists of keys which are provided by the environment.
            Config shouldn't reference any key that isn't available in all listed environments.""",
            allow_empty = True,
            allow_files = True,
            default = [],
        ),
        "header": attr.string(
            doc = "A string to include at the beginning of the output",
            mandatory = False,
        ),
        "out": attr.output(mandatory = True),
        "warnings": attr.bool(
            doc = """Specifies whether or not to see warnings about override config files with
            config keys not in the base config.""",
            default = False,
        ),
        "_hocon_compiler": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//hocon-compiler"),
        ),
    },
)
"""Compiles a hocon source to a flattened hocon config file.

This flattens the config, by merging with any included files as well as merging on top of an optional base config file.
It also check that any lucidBag references are valid.
"""
