

#--calling script as: 
./test1.sh
-->does NOT set env variables (export)
-->exit call within child exits only child
-->Recommendation: Use this & use exitCode to verify if execution is successful

#---calling script as (same as source):
. test1.sh
-->sets env variables (export) or any inner variables
-->exit call within child exits the parent session as well
-->Recommendation to use this to set env variables

#---------------parent--------------------
#!/bin/sh

echo "--parent--"


echo "--calling test1--"
./test1.sh
exitCode=$?
echo "exitCode"$exitCode
echo "TEST1="$TEST1
echo "v_test1="$v_test1

echo "--calling test2--"
./test2.sh
exitCode=$?
echo "exitCode"$exitCode
echo "TEST2="$TEST2

#--------child1:test1.sh------------
#!/bin/sh

echo "test1"
export TEST1="test1"
v_test1="V_TEST1"
exit 0

#--------child2:test2.sh-------
#!/bin/sh

echo "test2"
export TEST2="test2"
#---------------------------

Executiuon:
test_master.sh
(OR . test_master.sh )

--parent--
--calling test1--
test1
TEST1=
--calling test2--
test2
TEST2=

#----------------------------
