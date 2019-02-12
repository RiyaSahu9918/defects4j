#!/usr/bin/env bash
#
# Wrapper script for Evosuite
#
# Exported environment variables:
# D4J_HOME:                The root directory of the used Defects4J installation.
# D4J_FILE_TARGET_CLASSES: File that lists all target classes (one per line).
# D4J_FILE_ALL_CLASSES:    File that lists all relevant classes (one per line).
# D4J_DIR_OUTPUT:          Directory to which the generated test suite sources
#                          should be written (may not exist).
# D4J_DIR_WORKDIR:         Defects4J working directory of the checked-out
#                          project version.
# D4J_DIR_TESTGEN_LIB:     Directory that provides the libraries of all
#                          testgeneration tools.
# D4J_CLASS_BUDGET:        The budget (in seconds) that the tool should spend at
#                          most per target class.
# D4J_SEED:                The random seed.

# Check whether the D4J_DIR_TESTGEN_LIB variable is set
if [ -z "$D4J_DIR_TESTGEN_LIB" ]; then
    echo "Variable D4J_DIR_TESTGEN_LIB not set!"
    exit 1
fi

# Check whether the CRITERION variable is set
if [ -z "$CRITERION" ]; then
    echo "Variable CRITERION not set!"
    exit 1
fi

# Check whether the CONFIGURATION_ID variable is set
if [ -z "$CONFIGURATION_ID" ]; then
    echo "Variable CONFIGURATION_ID not set!"
    exit 1
fi

# General helper functions
source $D4J_DIR_TESTGEN_LIB/bin/_tool.util

#
# Global EvoSuite variables to collect data
#
EXECUTION_VARIABLES="configuration_id,group_id,Random_Seed,TARGET_CLASS,Size,Result_Size,Length,Result_Length,search_budget,Total_Time,criterion,Statements_Executed,Tests_Executed"
GA_VARIABLES="algorithm,Fitness_Evaluations,Generations,population,mutation_rate,crossover_function,crossover_rate,selection_function,rank_bias,tournament_size"
GOALS_VARIABLES="Total_Goals,Coverage,Lines,Covered_Lines,LineCoverage,Total_Branches,Covered_Branches,BranchCoverage,ExceptionCoverage,Mutants,WeakMutationScore,OutputCoverage,Total_Methods,MethodCoverage,MethodNoExceptionCoverage,CBranchCoverage,MutationScore"

DDU_VARIABLES="DDUScore"
VDDU_VARIABLES="VDDUScore"

#
# Timeline variables
#

EXTRA_TIMELINE_VARIABLES="CoverageTimeline,FitnessTimeline,SizeTimeline,LengthTimeline"
LINE_TIMELINE_VARIABLES="LineFitnessTimeline,LineCoverageTimeline"
BRANCH_TIMELINE_VARIABLES="BranchCoverageTimeline"
EXCEPTION_TIMELINE_VARIABLES="ExceptionFitnessTimeline,ExceptionCoverageTimeline,TotalExceptionsTimeline"
WEAKMUTATION_TIMELINE_VARIABLES="WeakMutationCoverageTimeline"
OUTPUT_TIMELINE_VARIABLES="OutputFitnessTimeline,OutputCoverageTimeline"
METHOD_TIMELINE_VARIABLES="MethodFitnessTimeline,MethodCoverageTimeline"
METHODNOEXCEPTION_TIMELINE_VARIABLES="MethodNoExceptionFitnessTimeline,MethodNoExceptionCoverageTimeline"
CBRANCH_TIMELINE_VARIABLES="CBranchFitnessTimeline,CBranchCoverageTimeline"
DDU_TIMELINE_VARIABLES="DDUFitnessTimeline" # TODO I believe it needs to be implemented
VDDU_TIMELINE_VARIABLES="VDDUFitnessTimeline" # TODO I believe it needs to be implemented

#
# Call the test generation for each target class
#

for class in $(cat $D4J_FILE_TARGET_CLASSES); do
    cmd="java -jar $D4J_DIR_TESTGEN_LIB/evosuite-current.jar \
        -mem 2048 \
        -Dshow_progress=false \
        -Duse_deprecated=true \
        -Dp_functional_mocking=0.8 \
        -Dfunctional_mocking_percent=0.5 \
        -Dp_reflection_on_private=0.5 \
        -Dreflection_start_percent=0.8 \
        -seed $D4J_SEED \
        -Dtest_archive=false \
        -Dsearch_budget=$D4J_CLASS_BUDGET \
        -Dstopping_condition=MaxTime \
        -Dcriterion=$CRITERION \
        -Danalysis_criteria=LINE,BRANCH,EXCEPTION,WEAKMUTATION,OUTPUT,METHOD,METHODNOEXCEPTION,CBRANCH,STRONGMUTATION \
        -Dtimeline_interval=10000 \
        -Doutput_variables=$EXECUTION_VARIABLES,$GA_VARIABLES,$GOALS_VARIABLES,$LINE_TIMELINE_VARIABLES,$BRANCH_TIMELINE_VARIABLES,$EXCEPTION_TIMELINE_VARIABLES,$WEAKMUTATION_TIMELINE_VARIABLES,$OUTPUT_TIMELINE_VARIABLES,$METHOD_TIMELINE_VARIABLES,$METHODNOEXCEPTION_TIMELINE_VARIABLES,$CBRANCH_TIMELINE_VARIABLES,$EXTRA_TIMELINE_VARIABLES,$DDU_TIMELINE_VARIABLES,$VDDU_TIMELINE_VARIABLES \
        -Dcoverage=true \
        -Dassertions=true \
        -Dassertion_strategy=ALL \
        -Dfilter_assertions=false \
        -Dinline=false \
        -Dminimize=false \
        -Djunit_tests=true \
        -Djunit_check=false \
        -Dtest_comments=false \
        -Dconfiguration_id=$CONFIGURATION_ID \
        -Dgroup_id=$class \
        -Dreport_dir=$D4J_DIR_OUTPUT \
        -Dtest_dir=$D4J_DIR_OUTPUT \
        -class $class \
        -projectCP $(get_project_cp) \
        -generateSuite"

    # Print the command that failed, if an error occurred.
    if ! $cmd; then
        echo
        echo "FAILED: $cmd"
        exit 1
    fi
done
