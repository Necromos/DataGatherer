#! /bin/bash
echo "Disc on"
rake classify:first_test[true]
rake classify:second_test[10,100,true]
rake classifu:third_test[true]
rake classify:fourth_test[true]
echo "Disc off"
rake classify:first_test[false]
rake classify:second_test[10,100,false]
rake classifu:third_test[false]
rake classify:fourth_test[false]
