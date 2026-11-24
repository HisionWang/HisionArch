name := "HisionArch"
organization := "hisionarch"
version := "0.1.0-SNAPSHOT"

// Compile the CPU directly from the pinned submodule.
lazy val hardwareAreas = Seq("accelerators", "soc", "memory", "common", "platform")

Compile / unmanagedSourceDirectories := {
  val root = baseDirectory.value
  hardwareAreas.map(area => root / "hardware" / area / "src" / "main" / "scala") :+
    (root / "hardware" / "cpu" / "miniXiangShan" / "src" / "main" / "scala")
}

Test / unmanagedSourceDirectories := {
  val root = baseDirectory.value
  hardwareAreas.map(area => root / "hardware" / area / "src" / "test" / "scala")
}

scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
  "-language:reflectiveCalls",
)

scalaVersion := "2.13.14"
val chiselVersion = "3.6.1"

libraryDependencies += "edu.berkeley.cs" %% "chisel3" % chiselVersion
libraryDependencies += "edu.berkeley.cs" %% "chiseltest" % "0.6.2"
libraryDependencies += "edu.berkeley.cs" %% "firrtl" % "1.6.0"
addCompilerPlugin("edu.berkeley.cs" %% "chisel3-plugin" % chiselVersion cross CrossVersion.full)
