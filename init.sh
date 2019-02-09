#!/usr/bin/env bash
#
################################################################################
# This script initializes Defects4J. In particular, it downloads and sets up:
# - the project's version control repositories
# - the Major mutation framework
# - the supported test generation tools
# - the supported code coverage tools (TODO)
################################################################################
# TODO: Major and the coverage tools should be moved to framework/lib

# Check whether wget is available
if ! wget --version > /dev/null 2>&1; then
    echo "Couldn't find wget to download dependencies. Please install wget and re-run this script."
    exit 1
fi

# Directories for project repositories and external libraries
BASE="$(cd $(dirname $0); pwd)"
DIR_REPOS="$BASE/project_repos"
DIR_LIB_GEN="$BASE/framework/lib/test_generation/generation"
DIR_LIB_RT="$BASE/framework/lib/test_generation/runtime"
DIR_LIB_GRADLE="$BASE/framework/lib/build_systems/gradle"
DIR_LIB_FL="$BASE/framework/lib/fault_localization"
mkdir -p "$DIR_LIB_GEN" && mkdir -p "$DIR_LIB_RT" && mkdir -p "$DIR_LIB_GRADLE" && mkdir -p "$DIR_LIB_FL"

################################################################################
#
# Download project repositories if necessary
#
echo "Setting up project repositories ... "
cd "$DIR_REPOS" && ./get_repos.sh

################################################################################
#
# Download Major
#
echo
echo "Setting up Major ... "
MAJOR_VERSION="1.3.2"
MAJOR_URL="http://mutation-testing.org/downloads"
MAJOR_ZIP="major-${MAJOR_VERSION}_jre7.zip"
cd "$BASE" && wget -nv -N "$MAJOR_URL/$MAJOR_ZIP" \
           && unzip -o "$MAJOR_ZIP" > /dev/null \
           && rm "$MAJOR_ZIP" \
           && cp major/bin/.ant major/bin/ant

################################################################################
#
# Download EvoSuite
#
echo
echo "Setting up EvoSuite ... "
EVOSUITE_VERSION="1.0.5"
#EVOSUITE_URL="https://github.com/EvoSuite/evosuite/releases/download/v${EVOSUITE_VERSION}"
EVOSUITE_JAR="evosuite-${EVOSUITE_VERSION}.jar"
EVOSUITE_RT_JAR="evosuite-standalone-runtime-${EVOSUITE_VERSION}.jar"
#cd "$DIR_LIB_GEN" && [ ! -f "$EVOSUITE_JAR" ] \
#                  && wget -nv "$EVOSUITE_URL/$EVOSUITE_JAR"
#cd "$DIR_LIB_RT"  && [ ! -f "$EVOSUITE_RT_JAR" ] \
#                  && wget -nv "$EVOSUITE_URL/$EVOSUITE_RT_JAR"
# Set symlinks for the supported version of EvoSuite
(cd "$DIR_LIB_GEN" && ln -sf "$EVOSUITE_JAR" "evosuite-current.jar")
(cd "$DIR_LIB_RT" && ln -sf "$EVOSUITE_RT_JAR" "evosuite-rt.jar")

################################################################################
#
# Download Randoop
#
echo
echo "Setting up Randoop ... "
RANDOOP_VERSION="4.0.4"
RANDOOP_URL="https://github.com/randoop/randoop/releases/download/v${RANDOOP_VERSION}"
RANDOOP_JAR="randoop-all-${RANDOOP_VERSION}.jar"
RANDOOP_AGENT_JAR="exercised-class-${RANDOOP_VERSION}.jar"
cd "$DIR_LIB_GEN" && [ ! -f "$RANDOOP_JAR" ] \
                && wget -nv "$RANDOOP_URL/$RANDOOP_JAR" \
                && wget -nv "$RANDOOP_URL/$RANDOOP_AGENT_JAR"
# Set symlink for the supported version of Randoop
ln -sf "$DIR_LIB_GEN/$RANDOOP_JAR" "$DIR_LIB_GEN/randoop-current.jar"
ln -sf "$DIR_LIB_GEN/$RANDOOP_AGENT_JAR" "$DIR_LIB_GEN/randoop-agent-current.jar"

#
# Download T3
#
echo
echo "Setting up T3 ... "
T3_URL="http://www.staff.science.uu.nl/~prase101/research/projects/T2/T3/T3_dist.zip"
T3_JAR="T3.jar"
cd "$DIR_LIB_GEN" && [ ! -f "$T3_JAR" ] \
                  && wget -nv "$T3_URL" \
                  && unzip -j T3_dist.zip "$T3_JAR" -d .
# Set symlink for the supported version of T3
ln -sf "$DIR_LIB_GEN/$T3_JAR" "$DIR_LIB_GEN/t3-current.jar"
ln -sf "$DIR_LIB_GEN/$T3_JAR" "$DIR_LIB_RT/t3-rt.jar"

#
# Download JTExpert and GRT
#
echo
echo "Setting up JTExpert and GRT ... "
# TODO: Download JTExpert and GRT from official release websites, once they exist.
JTE_GRT_URL="https://people.cs.umass.edu/~rjust/jte_grt.zip"
cd "$DIR_LIB_GEN" && [ ! -f grt.jar ] \
                  && wget -nv "$JTE_GRT_URL" \
                  && unzip jte_grt.zip
# Set symlink for the supported version of GRT and JTExpert
ln -sf "$DIR_LIB_GEN/grt.jar" "$DIR_LIB_GEN/grt-current.jar"
ln -sf "$DIR_LIB_GEN/JTExpert/JTExpert-1.4.jar" "$DIR_LIB_GEN/jtexpert-current.jar"

################################################################################
#
# Download GZoltar and other utility program(s) for fault localization
#
echo
echo "Setting up GZoltar and utility program(s) for fault localization ... "
GZOLTAR_VERSION="1.7.0"
GZOLTAR_FULL_VERSION="${GZOLTAR_VERSION}.201807090550"
GZOLTAR_URL="https://github.com/GZoltar/gzoltar/releases/download/v${GZOLTAR_VERSION}"
GZOLTAR_ZIP="gzoltar-${GZOLTAR_FULL_VERSION}.zip"
GZOLTAR_TMP_DIR="gzoltar_tmp_dir"
GZOLTAR_ANT_JAR="gzoltarant.jar"
GZOLTAR_AGENT_RT_JAR="gzoltaragent.jar"

cd "$DIR_LIB_FL" && [ ! -f "$GZOLTAR_ZIP" ] \
                 && wget -nv "$GZOLTAR_URL/$GZOLTAR_ZIP" \
                 && unzip -o -q "$GZOLTAR_ZIP" -d "$GZOLTAR_TMP_DIR" \
                 && mv "$GZOLTAR_TMP_DIR/lib/$GZOLTAR_ANT_JAR" . \
                 && mv "$GZOLTAR_TMP_DIR/lib/$GZOLTAR_AGENT_RT_JAR" . \
                 && rm -r "$GZOLTAR_TMP_DIR" "$GZOLTAR_ZIP"

# Set symlinks for the supported version of GZoltar
(cd "$DIR_LIB_FL" && ln -sf "$GZOLTAR_ANT_JAR" "gzoltar-ant-current.jar")
(cd "$DIR_LIB_FL" && ln -sf "$GZOLTAR_AGENT_RT_JAR" "gzoltar-agent-rt-current.jar")

LOCS_TO_STMS_VERSION="0.0.1"
LOCS_TO_STMS_URL="https://github.com/GZoltar/locs-to-stms/releases/download/v${LOCS_TO_STMS_VERSION}"
LOCS_TO_STMS_JAR="locs-to-stms-${LOCS_TO_STMS_VERSION}-jar-with-dependencies.jar"

cd "$DIR_LIB_FL" && [ ! -f "$LOCS_TO_STMS_JAR" ] \
                 && wget -nv "$LOCS_TO_STMS_URL/$LOCS_TO_STMS_JAR"
(cd "$DIR_LIB_FL" && ln -sf "$LOCS_TO_STMS_JAR" "locs-to-stms-current.jar")

################################################################################
#
# Download build system dependencies
#
echo
echo "Setting up Gradle dependencies ... "
GRADLE_ZIP=defects4j-gradle.zip
# The BSD version of stat does not support --version or -c
if stat --version &> /dev/null; then
    # GNU version
    cmd="stat -c %Y $GRADLE_ZIP"
else
    # BSD version
    cmd="stat -f %m $GRADLE_ZIP"
fi

cd "$DIR_LIB_GRADLE"
if [ -e $GRADLE_ZIP ]; then
    old_ts=$($cmd)
else
    old_ts=0
fi
# Only download archive if the server has a newer file
wget -N http://people.cs.umass.edu/~rjust/defects4j/download/$GRADLE_ZIP
new=$($cmd)

# Update gradle versions if a newer archive was available
[ "$old" != "$new" ] && unzip -q -u $GRADLE_ZIP

cd "$BASE"
echo
echo "Defects4J successfully initialized."
