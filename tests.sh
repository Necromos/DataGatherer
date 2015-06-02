#! /bin/bash
echo "Disc on"
rake classify:first_test[true]
rake classify:third_test[true]
rake classify:fourth_test[true]
echo "10000 runs 2-5 folds"
for i in 2 3 4 5
do
  rake classify:second_test[$i,10000,true]
  rake classify:fifth_test[$i,10000,true]
  rake classify:sixth_test[$i,10000,true]
done
echo "Disc off"
rake classify:first_test[false]
rake classify:third_test[false]
rake classify:fourth_test[false]
for i in 2 3 4 5
do
  rake classify:second_test[$i,10000,false]
  rake classify:fifth_test[$i,10000,false]
  rake classify:sixth_test[$i,10000,false]
done
