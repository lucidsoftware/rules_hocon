load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//rules:hocon.bzl", "hocon_library")

# This flag is set on the test-only "hocon-jvm-flags" toolchain in this package's BUILD.bazel. The
# test asserts it propagates to the HoconCompile action's command line as `--jvm_flag=<flag>`. The
# jvm_flags are intentionally kept out of the params file, so they appear inline in argv.
_EXPECTED_JVM_FLAG = "--jvm_flag=-Drules_hocon.test=1"

def _jvm_flags_propagated_test_impl(ctx):
    env = analysistest.begin(ctx)

    hocon_actions = [
        action
        for action in analysistest.target_actions(env)
        if action.mnemonic == "HoconCompile"
    ]
    asserts.true(
        env,
        len(hocon_actions) > 0,
        "expected at least one HoconCompile action",
    )
    for action in hocon_actions:
        asserts.true(
            env,
            _EXPECTED_JVM_FLAG in action.argv,
            "expected {} in the HoconCompile command line, got: {}".format(
                _EXPECTED_JVM_FLAG,
                action.argv,
            ),
        )

    return analysistest.end(env)

jvm_flags_propagated_test = analysistest.make(
    _jvm_flags_propagated_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/jvm_flags:hocon-jvm-flags"],
    },
)

def hocon_jvm_flags_test_suite(name):
    """Verifies that a HOCON toolchain's jvm_flags reach the HoconCompile action.

    Args:
        name: Name of the generated analysis test target.
    """
    hocon_library(
        name = "jvm-flags-config",
        src = "config.conf",
        out = "jvm-flags.conf",
        tags = ["manual"],
    )

    jvm_flags_propagated_test(
        name = name,
        target_under_test = ":jvm-flags-config",
    )
