miktex-xetex.exe -synctex=1 -undump=xelatex %1.tex
::"E:\Programs Windows\pdf2svg-windows-master\dist-64bits\pdf2svg.exe" %1.pdf %1.svg
convert -density 600 %1.pdf -quality 90 %1.png
::%1.png
