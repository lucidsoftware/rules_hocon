def hocon_repositories():
    native.maven_jar(
        name = "hocon_com_typesafe_config",
        artifact = "com.typesafe:config:1.3.3",
        sha1 = "4b68c2d5d0403bb4015520fcfabc88d0cbc4d117",
        sha1_src = "c7af5bd41815a5edc8e7a81082e88fe18f9729e0",
    )

    native.maven_jar(
        name = "hocon_org_rogach_scallop_2_11",
        artifact = "org.rogach:scallop_2.11:3.1.3",
        sha1 = "5cd8166a3ca2b78fc7e2ceafc0616c756b9edeee",
        sha1_src = "914a1f1d8fcb0d811c4fba8d2ab0e07f53694181",
    )
