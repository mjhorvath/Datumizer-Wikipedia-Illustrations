latex %1.tex
::pdflatex --shell-escape %1.tex
::pause
dvips -E %1.dvi
::eps2eps -dNOCACHE %1.ps %1.eps
::ps2epsi %1.eps %1.ps
ps2pdf -dAutoRotatePages#/None %1.ps
::"E:\Programs Windows\pdf2svg-windows-master\dist-64bits\pdf2svg.exe" %1.pdf %1.svg
convert -density 600 %1.pdf -quality 90 %1.png
::%1.png
