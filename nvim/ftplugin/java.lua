local jdtls = require "jdtls"
local root = require("jdtls.setup").find_root { "build.gradle", "gradlew", ".git" }

jdtls.start_or_attach {
  cmd = { "jdtls" },
  root_dir = root,
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/usr/lib/jvm/java-21-openjdk",
          },
        },
      },
      project = {
        referencedLibraries = {
          "/opt/android-sdk/platforms/android-34/android.jar",
        },
      },
      format = { enabled = true },
    },
  },
}
