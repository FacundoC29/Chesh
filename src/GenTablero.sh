#!/bin/bash

 #paste -d '' <(cat piezasP.txt) <(cat piezasP.txt)

#DECLARO LA "MATRIZ" DEL TABLERO INICIAL

declare -A tablero

#declaro negras
tablero[a1]="wR1"
tablero[b1]="wN1"
tablero[c1]="wB1"
tablero[d1]="wQ"
tablero[e1]="wK"
tablero[f1]="wB2"
tablero[g1]="wN2"
tablero[h1]="wR2"

tablero[a2]="wP1"
tablero[b2]="wP2"
tablero[c2]="wP3"
tablero[d2]="wP4"
tablero[e2]="wP5"
tablero[f2]="wP6"
tablero[g2]="wP7"
tablero[h2]="wP8"

#for de las casillas vacias para ahorrar codigo

#aparentemente me da error aca abajo porque me dice "orden no encontrada"

letras=("a" "b" "c" "d" "e" "f" "g" "h")
for (( l=0; l<8; l++ )); do
	for (( n=1; n<9; n++ )); do
	laux="${letras[$l]}"	
	tablero["$laux$n"]=""
	done
done

#declaro negras
tablero[a8]="bR1"
tablero[b8]="bN1"
tablero[c8]="bB1"
tablero[d8]="bQ"
tablero[e8]="bK"
tablero[f8]="bB2"
tablero[g8]="bN2"
tablero[h8]="bR2"

tablero[a7]="bP1"
tablero[b7]="bP2"
tablero[c7]="bP3"
tablero[d7]="bP4"
tablero[e7]="bP5"
tablero[f7]="bP6"
tablero[g7]="bP7"
tablero[h7]="bP8"


#Como cada vez que hago un cat se resetea el cursor (baja una fila),
#y no tiene sentido que haga un algoritmo involucrando al cursor con tput,
#junto los contenidos de cada fila en una variable auxiliar para catearlos todos de una
#cuando termine la fila, cambia el for de arriba y el siguiente cat se va a hacer en otra fila



for (( f=0; f<9; f++ )); do
	if (( f != 0 )); then		
		paste -d '' <(cat ${rFila[0]}) <(cat ${rFila[1]}) <(cat ${rFila[2]}) <(cat ${rFila[3]}) <(cat ${rFila[4]}) <(cat ${rFila[5]}) <(cat ${rFila[6]}) <(cat ${rFila[7]})   		
	fi
		
	if (( f % 2 == 0 )); then

		for (( c=0; c<8; c++ )); do
	   		 if (( c % 2 == 0 )); then
	      			rFila[c]="wT"
	    		 else
	      			rFila[c]="bT" 
	    		 fi
	  	done
	else
		for (( c=0; c<8; c++ )); do
	   		 if (( c % 2 == 0 )); then
	      			rFila[c]="bT" 
	    		 else
	      			rFila[c]="wT"
	    		 fi
	  	done
	fi
done

