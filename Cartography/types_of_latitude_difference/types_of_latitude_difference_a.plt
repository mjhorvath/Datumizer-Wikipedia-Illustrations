set term png small notransparent
 set output "types_of_latitude_difference_a.png"
 
 set title "Types of Latitude"
 set xlabel "Common Latitude (Degrees)"
 set xtics nomirror 0,5,90
 set xrange [-1:91]
 
 set ylabel "Difference from Common Latitude (Minutes)"
 set ytics nomirror 0,1,12
 set yrange [-1:13]
 
 set size 0.8,0.8
 
 set key left top
 
 plot \
     "data_difference.dat" using 1:2 title 'Common', \
     "data_difference.dat" using 1:3 title 'Reduced', \
     "data_difference.dat" using 1:4 title 'Authalic', \
     "data_difference.dat" using 1:5 title 'Rectifying', \
     "data_difference.dat" using 1:6 title 'Conformal', \
     "data_difference.dat" using 1:7 title 'Geocentric'
