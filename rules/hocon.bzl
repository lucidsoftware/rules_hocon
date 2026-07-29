"""Lucid Hocon compilation rules

Bazel rules for compiling multiple HOCON source files into a flattend HOCON artifact.

In addition to checking syntax and flattening the configuration files, it also verifies that
any references (`${}` syntax) either refer to internal config, or keys from an allowlist of
config that will provided at runtime.

[HOCON](https://github.com/lightbend/config)

"""

def _hocon_library_impl(ctx):
    hocon_toolchain = ctx.toolchains["//hocon-toolchain:toolchain_type"]

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
        # Headers can be multiline, we write the header to a file to make parsing it easier in the worker
        header_file = ctx.actions.declare_file(ctx.label.name + "_header.txt")
        ctx.actions.write(
            output = header_file,
            content = ctx.attr.header,
        )
        args.add("--header", header_file)
        all_inputs.append(header_file)

    if not ctx.attr.include_comments:
        args.add("--nocomments")

    if ctx.attr.resolve:
        args.add("--resolve")

    if ctx.attr.json:
        args.add("--json")

    args.add_all("-D", ctx.attr.optional_includes, omit_if_empty = True, uniquify = True)

    if ctx.attr.warnings:
        args.add("--warnings")
    if ctx.attr.allow_missing_keys:
        args.add("--allow-missing")
    args.add(ctx.file.src)

    args.set_param_file_format("multiline")
    args.use_param_file("@%s", use_always = True)

    # These args are read by the worker launcher script rather than the param file, which is why
    # they're kept in a separate args object from the param-file args.
    jvm_flag_args = ctx.actions.args()
    jvm_flag_args.add_all(
        hocon_toolchain.jvm_flags,
        format_each = "--jvm_flag=%s",
    )

    ctx.actions.run(
        arguments = [jvm_flag_args, args],
        executable = hocon_toolchain.hocon_compiler.files_to_run,
        execution_requirements = {
            "supports-workers": "1",
            "supports-multiplex-workers": "1",
            "supports-multiplex-sandboxing": "1",
            "supports-worker-cancellation": "1",
            "supports-path-mapping": "1",
        },
        inputs = all_inputs,
        mnemonic = "HoconCompile",
        outputs = [ctx.outputs.out],
        progress_message = "Compiling hocon config (%s)" % ctx.label.name,
        toolchain = "//hocon-toolchain:toolchain_type",
    )

hocon_library = rule(
    implementation = _hocon_library_impl,
    doc = """Compiles a hocon source to a flattened hocon config file.

    This flattens the config, by merging with any included files as well as merging on top of an optional base config file.
    It also checks that any lucidBag references are valid.
    """,
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
        "allow_missing_keys": attr.bool(
            doc = """Specifies whether or not to allow config keys that could not be resolved.""",
            default = False,
        ),
        "include_comments": attr.bool(
            doc = "If false, suppress all comments in the output. This removes comments from the original source",
            default = True,
        ),
        "resolve": attr.bool(
            doc = """If true, the output will resolve any references where possible, so that the only remaining references are to values that will be supplied at runtime.

            This should only be set to true if ther are no downstream dependencies of the resulting configuration. Otherwise, downstream dependencies won't be able to correctly override
            any configuration values that are referenced in other config values. There are also some edge cases where resolving can produce unexpected output.
            """,
            default = False,
        ),
        "json": attr.bool(
            doc = """If true, then output in  a json-like format.
            Note that it may include comments and references that aren't actually valid JSON""",
            default = False,
        ),
    },
    toolchains = ["//hocon-toolchain:toolchain_type"],
)
