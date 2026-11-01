#!/bin/bash

#ASSETS

source "$(dirname "${BASH_SOURCE[0]}")/assets/sprites.sh"


rCols=370
rLines=91

if [[ $(tput cols) -lt $rCols || $(tput lines) -lt $rLines ]]; then
	echo "La resolución de la terminal es demasiado pequeña para ejecutar el juego. Se recomienda una resolución de al menos ${rCols}x${rLines} (columnas x filas)."
	exit 1
fi



#paste -d '' <(cat piezasP.txt) <(cat piezasP.txt)

#DECLARO LA "MATRIZ" DEL TABLERO INICIAL

clear

tput cup 0 0;

declare -A tablero

declare -A letrasInv

letras=("a" "b" "c" "d" "e" "f" "g" "h")

#Aprovecho este for para ahorrar lineas llenando el tablero con espacios vacios
#y ademas aprovecho que recorre las letras para tener un acceso directo al indice del array de letras usando el valor del array letras como indice del inverso
for (( l=0; l<8; l++ )); do
	for (( n=1; n<9; n++ )); do
		laux="${letras[$l]}"	
		tablero["$laux$n"]=""
		
		letrasInv[$laux]=$l	
	
	done
done

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

#Para myor control es casos especificos y mayor velocidad de lectura, declaro otro arreglo.
#Esta vez, de la posicion de las piezas teniendo las piezas como referencia, no al reves
#Ademas, en este SI se distinguen las piezas iguales

declare -A PosPiezas

PosPiezas[wR1]="a1"
PosPiezas[wN1]="b1"
PosPiezas[wB1]="c1"
PosPiezas[wQ]="d1"
PosPiezas[wK]="e1"
PosPiezas[wB2]="f1"
PosPiezas[wN2]="g1"
PosPiezas[wR2]="h1"

PosPiezas[wP1]="a2"
PosPiezas[wP2]="b2"
PosPiezas[wP3]="c2"
PosPiezas[wP4]="d2"
PosPiezas[wP5]="e2"
PosPiezas[wP6]="f2"
PosPiezas[wP7]="g2"
PosPiezas[wP8]="h2"

PosPiezas[bR1]="a8"
PosPiezas[bN1]="b8"
PosPiezas[bB1]="c8"
PosPiezas[bQ]="d8"
PosPiezas[bK]="e8"
PosPiezas[bB2]="f8"
PosPiezas[bN2]="g8"
PosPiezas[bR2]="h8"

PosPiezas[bP1]="a7"
PosPiezas[bP2]="b7"
PosPiezas[bP3]="c7"
PosPiezas[bP4]="d7"
PosPiezas[bP5]="e7"
PosPiezas[bP6]="f7"
PosPiezas[bP7]="g7"
PosPiezas[bP8]="h7"

#Declaro arrays de movimientos legales y datos especiales

#condicion (DESCARTADA) si es blanco y esta en fila 2 || es negro y esta en fila 7

declare -a mlP
declare -A primerMP
declare -A PMov2 #para asegurarnos de que ademas de que el peon movio en el mismo turno, haya movido dos casillas de una
			#es mas eficiente que la condicion de arriba porque me ahorro un OR y tener que usar la funcion leerCas
			#solamente se fija el valor de su indice en el array declarativo PMov2, que emula un boolean array
for (( i=1;i<9;i++));do
primerMP[wP$i]=""
PMov2[wP$i]="" #OBLIGATORIAMENTE tiene que tener un nulo porque sino el peon podria llegar en 2 movimientos a destino ( A CHEQUEAR ) (creo que por mejor funcionamiento de la logica, 0 es que movio 1, 1 es que movio 2, null es que aun no movio)
done
for (( i=1;i<9;i++));do
primerMP[bP$i]=""
PMov2[bP$i]=""
done

#Como cada vez que hago un cat se resetea el cursor (baja una fila),
#y no tiene sentido que haga un algoritmo involucrando al cursor con tput,
#junto los contenidos de cada fila en una variable auxiliar para catearlos todos de una
#cuando termine la fila, cambia el for de arriba y el siguiente cat se va a hacer en otra fila



dibujarDerecha() {
    local nombre="$1"
    local columna="$2"
    local fila=1
    local linea
    local arte="${iconos[$nombre]}"

    printf '\033[s'

    while IFS= read -r linea || [[ -n "$linea" ]]; do
        printf '\033[%d;%dH%s' "$fila" "$columna" "$linea"
        ((fila++))
    done <<< "$arte"

    printf '\033[u'
}

function renderizarT() {
	
	clear
	if (( turno % 2 == 0 )); then
		for (( f=8; f>=1; f-- )); do
			renderizarTfor
		done	
	else
		for (( f=1; f<=8; f++ )); do
			renderizarTfor
		done
	fi
	
	dibujarDerecha tuxConcentrado 180
}


#Funcion de mover las piezas
#Dentro actua como un menu para ver que piezas se pueden o se tienen que mover
mover(){

	echo "Que pieza quieres mover? (selecciona la casilla en la que se encuentra)"
	read cselect
	echo "A que casilla quieres moverla?"
	read cDestino
	pselect="${tablero[$cselect]}"

		case $pselect in
			*P*)
			intentarMP
			;;
			
			*R*)
			intentarMR
			;;

			*N*)
			intentarMN
			;;

			*B*)
			intentarMB
			;;

			*Q*)
			intentarMQ
			;;

			*K*)
			intentarMK
			;;

			*)
			echo "default"
			;;
		esac
#reiniciar arrays

#sumar un turno

}
#IMPORTANTISIMO!!!!!!!!! Para todos los intentarMX, tengo que tener un array de movimientos prohibidos por dejar en descubierto al rey, asi si justo suceden se evitan
#Luego voy a tener que agregarle esa condicion a todos los if decisivos de "efectuarMov"

intentarMP(){ #FALTA C REY!!
	leerCas
	local lnCompar=""

	#1) mueve 1 adelante ( y si no se choca) 
		
	if [[ $muevenB == true ]];then	
		local numAux=$((num + 1 ))
	else
		local numAux=$((num -1 ))	
	fi	
	
	if [[ -z "${tablero[$letra$numAux]}" && $cDestino == "${letra}${numAux}" ]];then
		efectuarMov 
		echo "movimiento efectuado"
	fi

	#2) mueve 2 adelante si es el primer movimiento (si no se choca) + guarda para recibir en passant 
	if [[ -z "${primerMP[$pselect]}" &&  $cDestino == ${letra}$((num + 2)) ||  $cDestino == ${letra}$((num - 2)) && -z "${tablero[$letra$numAux]}" ]];then
		
		primerMP[$pselect]=$turno
		PMov2[$pselect]=true
		efectuarMov
		
	fi

	#3) "comer normal"
	indL=${letrasInv[$letra]}
	
		
	if [[ $muevenB == true ]];then	
	 numAux=$((num + 1 ))
	else
	 numAux=$((num -1 ))
	fi	

	#tengo entendido que este if es mas eficiente con comparaciones aritmeticas (no necesita -eq ni nada de eso)		
	if (( indL - 1 >= 0 ));then #<--- con este
		indLetraA=$(( indL-1 ))
		letraA=${letras[$indLetraA]} 
	fi	
	if ((indL + 1 <= 7 ));then #<--- y este if guardo las casillas a la izq. y der. de la casilla de enfrente al peon (donde puede comer)
		indLetraB=$(( indL+1 ))
		letraB=${letras[$indLetraB]}	
	fi

	if [[ "${letraA}${numAux}" == $cDestino ]]; then
		if [[ "${tablero[$cDestino]}" != "" ]];then 
			if [[ $muevenB == true ]];then
				if [[ "${tablero[$cDestino]}" == b* ]];then
					efectuarMov	
				else
					echo "Movimiento invalido (pieza del mismo color)"						
				fi			
			elif [[ "${tablero[$cDestino]}" == w* ]];then
					efectuarMov	
				else						
					echo "Movimiento invalido (pieza del mismo color)"
				fi	
					
			fi
		fi				
	
	if [[ "${letraB}${numAux}" == $cDestino ]]; then
		if [[ "${tablero[$cDestino]}" != "" ]];then 
			if [[ $muevenB == true ]];then
				if [[ "${tablero[$cDestino]}" == b* ]];then
					efectuarMov	
				else
					echo "Movimiento invalido (pieza del mismo color)"						
				fi			
			elif [[ "${tablero[$cDestino]}" == w* ]];then
					efectuarMov	
				else						
					echo "Movimiento invalido (pieza del mismo color)"
			fi	
					
		fi
	fi				
	
	
	#PROGRAMAR CASO DE COMER NORMAL Y EN PASSANT
	#HACER QUE SI LLEGA AL FINAL Y LA CASILLA DESEADA NO ERA NINGUNA DE LAS POSIBLES, QUE SE GUARDE mlP de esa pieza para que no se tenga que recalcular.
}
intentarMR(){
leerCas	
mlR=()
#1.Buscar movimientos legales
	#i) Desde uno mas de la casilla de la torre hasta la fila 8 inclusive
	if (( num + 1 < 8 )); then
		for (( i=( $num + 1 ); i<=8; i++ ));do
			if [[ $muevenB == true ]];then		
				if [[ -z "${tablero[$letra$i]}" ]];then
					mlR+=("$letra$i")
				elif [[ ${tablero[$letra$i]} == b* ]]; then
					mlR+=("$letra$i")
					break
				fi
						
		
			else #si mueven negras
				if [[ -z "${tablero[$letra$i]}" ]];then
					mlR+=("$letra$i")
				elif [[ ${tablero[$letra$i]} == w* ]]; then
					mlR+=("$letra$i")
					break
				fi
			fi
		
		done
	fi	
	#ii) Desde uno menos de la casilla de la torre hasta la fila 1 inclusive
	if (( $num - 1 > 1 )); then
		for (( i=( $num - 1 ); i>=1; i-- ));do
			
			if [[ $muevenB == true ]];then		
				if [[ -z "${tablero[$letra$i]}" ]];then
					mlR+=("$letra$i")
				elif [[ ${tablero[$letra$i]} == b* ]] ; then
					mlR+=("$letra$i")
					break
				fi
						
		
			else #si mueven negras
				if [[ -z "${tablero[$letra$i]}" ]];then
					mlR+=("$letra$i")
				elif [[ ${tablero[$letra$i]} == w* ]]; then
					mlR+=("$letra$i")
					break
				fi
			fi
		
		done
	fi
	#iii) Desde una COLUMNA mas de la casilla de la torre hasta la COLUMNA 8 (h) inclusive
	letraux="$letra" #para que no falle la funcion de efectuar el movimiento
	letrauxinv="${letrasInv[$letraux]}"		
	#Aca se complica porque tengo que estar convirtiendo la letra a indice	
	
	if (( letrauxinv + 1 < 8 )); then
		for (( i=( $letrauxinv + 1 ); i<=7; i++ ));do #CORREGI ERROR DE INDICE, tiene que ser 7 por el indice del array letrasinv
			if [[ $muevenB == true ]];then		
				if [[ -z "${tablero[${letras[$i]}$num]}" ]];then
					mlR+=(${letras[$i]}$num)
				elif [[ ${tablero[${letras[$i]}$num]} == b* ]]; then
					mlR+=(${letras[$i]}$num)
					break
				fi
						
		
			else #si mueven negras
				if [[ -z "${tablero[$letra$i]}" ]];then
					mlR+=(${letras[$i]}$num)
				elif [[ ${tablero[$letra$i]} == w* ]]; then
					mlR+=(${letras[$i]}$num)
					break
				fi
			fi
		
		done
	fi
	#iv) Desde una COLUMNA mas de la casilla de la torre hasta la COLUMNA 1 (a) inclusive
	if (( letrauxinv - 1 > 1 )); then
		for (( i=( $letrauxinv - 1 ); i>=0; i-- ));do
			if [[ $muevenB == true ]];then		
				if [[ -z "${tablero[${letras[$i]}$num]}" ]];then
					mlR+=(${letras[$i]}$num)
				elif [[ ${tablero[${letras[$i]}$num]} == b* ]]; then
					mlR+=(${letras[$i]}$num)
					break
				fi
						
		
			else #si mueven negras
				if [[ -z "${tablero[$letra$i]}" ]];then
					mlR+=(${letras[$i]}$num)
				elif [[ ${tablero[$letra$i]} == w* ]]; then
					mlR+=(${letras[$i]}$num)
					break
				fi
			fi
		
		done		
	fi


#2.Mover (si se puede)
		for movPos in "${mlR[@]}"; do
			if [[ "$movPos" == "$cDestino" ]]; then
				efectuarMov
				break
			fi

		done
				
}
intentarMN(){ #podria tratar de hacerlo lo mas optimo posible y que cuadno encuentre el movimiento haga el break o que recorra todo
	leerCas
	letraux="$letra" #para que no falle la funcion de efectuar el movimiento
	letrauxinv="${letrasInv[$letraux]}"		
	mlN=()

	# i) Doble L vertical arriba	
	ref=$((num + 2)) # voy 3 casillas arriba
	revisarLV
	
	# ii) Doble L vertical abajo	
	ref=$((num - 2)) # voy 3 casillas abajo	
	revisarLV

	# iii) Doble L horizontal izquierda
	ref=$((letrauxinv - 2)) #voy 3 casillas a la izquierda
	revisarLH

	# iii) Doble L horizontal derecha
	ref=$((letrauxinv + 2)) #voy 3 casillas a la derecha
	revisarLH

	for movPos in "${mlN[@]}"; do
			if [[ "$movPos" == "$cDestino" ]]; then
				efectuarMov
				break
			fi

			done
}
revisarLV(){

		#Reviso casilla a la izquierda (-1)
		if [[  -z "${tablero[${letras[$((letrauxinv-1))]}$ref]}" ]];then #reviso contenido de la casilla
			mlN+=("${letras[$((letrauxinv-1))]}$ref")  #agrego POSICION
		elif [[ $muevenB == true ]]; then
			if [[ ${tablero[${letras[$((letrauxinv-1))]}$ref]} == b* ]];then
				mlN+=("${letras[$((letrauxinv-1))]}$ref") 
			fi
		else
			if [[ ${tablero[${letras[$((letrauxinv-1))]}$ref]} == w* ]];then

				mlN+=("${letras[$((letrauxinv-1))]}$ref") 
			fi
		fi

		#Reviso casilla a la derecha (+1)
		if [[  -z "${tablero[${letras[$((letrauxinv+1))]}$ref]}" ]];then
			mlN+=("${letras[$((letrauxinv+1))]}$ref") 

		elif [[ $muevenB == true ]]; then
			if [[ ${tablero[${letras[$((letrauxinv+1))]}$ref]} == b* ]];then

				mlN+=("${letras[$((letrauxinv+1))]}$ref") 
			fi
		else
			if [[ ${tablero[${letras[$((letrauxinv+1))]}$ref]} == w* ]];then
				mlN+=("${letras[$((letrauxinv+1))]}$ref") 

			fi

		fi
	
}
revisarLH(){
	
		#Reviso casilla a la izquierda (-1)
		if [[  -z "${tablero[$ref$((num-1))]}" ]];then
			mlN+=("$ref$((num-1))")
		elif [[ $muevenB == true ]]; then
			if [[ "${tablero[$ref$((num-1))]}" == b* ]];then
				mlN+=("$ref$((num-1))")
			fi
		else
			if [[ "${tablero[$ref$((num-1))]}" == w* ]];then
				mlN+=("$ref$((num-1))")
			fi

		fi

		#Reviso casilla a la derecha (+1)
		if [[  -z "${tablero[$ref$((num+1))]}" ]];then
			mlN+=("$ref$((num+1))")
		elif [[ $muevenB == true ]]; then
			if [[ "${tablero[$ref$((num+1))]}" == b* ]];then
				mlN+=("$ref$((num+1))")
			fi
		else
			if [[ "${tablero[$ref$((num+1))]}" == w* ]];then
				mlN+=("$ref$((num+1))")
			fi

		fi
		
}

leerCas(){
	cadena=$cselect
	letra=${cadena:0:1}
	num=${cadena:1:1}
}

efectuarMov(){
	tablero[$cDestino]=$pselect
	tablero[$cselect]=""
	cselect=""
	cDestino=""
	turno=$(( turno + 1 ))
	if (( turno % 2 == 0 ));then
		muevenB=true
	else
		muevenB=false
	fi		
	renderizarT
}

renderizarTfor(){

	if (( (f +1) % 2 == 0 )); then #en el else de este if invierto el orden de lectura
		
			for (( c=0; c<8; c++ )); do

		   		laux="${letras[$c]}"	
				
				 if (( c % 2 == 0 )); then
					if [ -z "${tablero[$laux$f]}" ]; then	      			
						rFila[c]="wT"
			    		else
							switch="${tablero[$laux$f]}"
							case $switch in
								wP*) #Lo que sea que empiece por x codigo de pieza (para evitar ors sin sentido)	
								rFila[c]="wPw"
								;;
								
								wR*)
								rFila[c]="wRw"
								;;
								
								wN*)
								rFila[c]="wNw"
								;;
								
								wB*)
								rFila[c]="wBw"
								;;

								wQ*)
								rFila[c]="wQw"
								;;

								wK*)
								rFila[c]="wKw"
								;;

								bP*) #Negras casilla blanca:	
								rFila[c]="bPw"
								;;
								
								bR*)
								rFila[c]="bRw"
								;;
								
								bN*)
								rFila[c]="bNw"
								;;
								
								bB*)
								rFila[c]="bBw"
								;;

								bQ*)
								rFila[c]="bQw"
								;;

								bK*)
								rFila[c]="bKw"
								;;
							esac
						fi

					 else # Abajo de este else esta cargado el switch con las piezas en casilla negra
		      				if [ -z "${tablero[$laux$f]}"  ]; then	      			
						rFila[c]="bT"
			    			else
							switch="${tablero[$laux$f]}"
							case $switch in
						
								wP*) #Lo que sea que empiece por x codigo de pieza (para evitar ors sin sentido)	
								rFila[c]="wPb"
								;;
								
								wR*)
								rFila[c]="wRb"
								;;
								
								wN*)
								rFila[c]="wNb"
								;;
								
								wB*)
								rFila[c]="wBb"
								;;

								wQ*)
								rFila[c]="wQb"
								;;

								wK*)
								rFila[c]="wKb"
								;;

								bP*) #Negras casilla negra:	
								rFila[c]="bPb"
								;;
								
								bR*)
								rFila[c]="bRb"
								;;
								
								bN*)
								rFila[c]="bNb"
								;;
								
								bB*)
								rFila[c]="bBb"
								;;

								bQ*)
								rFila[c]="bQb"
								;;

								bK*)
								rFila[c]="bKb"
								;;
											
							esac
						fi	    		 
				fi
			done
		else #SI LA FILA ES IMPAR, HACEMOS LO MISMO AL REVES
			for (( c=0; c<8; c++ )); do
		   		laux="${letras[$c]}"			
					 if (( c % 2 == 0 )); then
						if [ -z "${tablero[$laux$f]}"  ]; then	      			
							rFila[c]="bT"
			    			else
							switch="${tablero[$laux$f]}"
							case $switch in
								wP*) #Lo que sea que empiece por x codigo de pieza (para evitar ors sin sentido)	
								rFila[c]="wPb"
								;;
								
								wR*)
								rFila[c]="wRb"
								;;
								
								wN*)
								rFila[c]="wNb"
								;;
								
								wB*)
								rFila[c]="wBb"
								;;

								wQ*)
								rFila[c]="wQb"
								;;

								wK*)
								rFila[c]="wKb"
								;;

								bP*) #Negras casilla negra:	
								rFila[c]="bPb"
								;;
								
								bR*)
								rFila[c]="bRb"
								;;
								
								bN*)
								rFila[c]="bNb"
								;;
								
								bB*)
								rFila[c]="bBb"
								;;

								bQ*)
								rFila[c]="bQb"
								;;

								bK*)
								rFila[c]="bKb"
								;;
							esac
						fi

					 else # Abajo de este else esta cargado el switch con las piezas en casilla blanca PORQUE ES FILA IMPAR
		      				if [ -z "${tablero[$laux$f]}"  ]; then	      			
						rFila[c]="wT"
			    			else
							switch="${tablero[$laux$f]}"
							case $switch in
						
								wP*) #Lo que sea que empiece por x codigo de pieza (para evitar ors sin sentido)	
								rFila[c]="wPw"
								;;
								
								wR*)
								rFila[c]="wRw"
								;;
								
								wN*)
								rFila[c]="wNw"
								;;
								
								wB*)
								rFila[c]="wBw"
								;;

								wQ*)
								rFila[c]="wQw"
								;;

								wK*)
								rFila[c]="wKw"
								;;

								bP*) #Negras casilla blanca:	
								rFila[c]="bPw"
								;;
								
								bR*)
								rFila[c]="bRw"
								;;
								
								bN*)
								rFila[c]="bNw"
								;;
								
								bB*)
								rFila[c]="bBw"
								;;

								bQ*)
								rFila[c]="bQw"
								;;

								bK*)
								rFila[c]="bKw"
								;;
											
							esac
						fi	    		 
					fi
				done			
			fi

	paste -d '' \
    <(printf '%s\n' "${sprites[${rFila[0]}]}") \
    <(printf '%s\n' "${sprites[${rFila[1]}]}") \
    <(printf '%s\n' "${sprites[${rFila[2]}]}") \
    <(printf '%s\n' "${sprites[${rFila[3]}]}") \
    <(printf '%s\n' "${sprites[${rFila[4]}]}") \
    <(printf '%s\n' "${sprites[${rFila[5]}]}") \
    <(printf '%s\n' "${sprites[${rFila[6]}]}") \
    <(printf '%s\n' "${sprites[${rFila[7]}]}")
		#done
}
#EMPIEZA EL MAIN



printf '\033[2J\033[3J\033[H' #hace lo mismo que un clear pero funciona mejor con el historial de la terminal, y ademas no hace que se mueva el cursor a la esquina superior izquierda, sino que lo deja en la posicion en la que estaba antes del clear

printf '%s\n' "${sprites[titleC]}" | expand -t 4
while IFS= read -r linea; do
    printf '%40s%s\n' '' "$linea"
done <<< "${sprites[Dama]}"
read -sn1 start

printf '\033[2J\033[3J\033[H'

turno=0
muevenB=true
renderizarT
mate=0

while [ $mate=0 ];do
	mover	
done

# Me confundi haciendo esto pero me va  a servir para movimiento lateral
	
	#indL=${letrasInv[$letra]}
	#letra=

#VERIFICAR SI NO ES MEJOR COMPARAR YA A RAIZ DE  (en funcion peones) $cselect (DESCARTADA) --> Asi puedo seguir la misma logica con las otras piezas. Hacer eso con la dama, por ejemplo seria totalmente inviable.

#PROBLEMAS PENDIENTES
#1.EFECTUAR MOV NO ACTUALIZA POSPIEZAS
#2.ADAPTAR INTENTARMP PARA QUE FUNCIONE CON NEGRAS (SIEMPRE HACE FILA+1)
#3. EL IF DE 2 CASILLAS INTENTARMP NO VERIFICA SI AMBAS ESTAN LIBRES
#4. FALTA RESTRINGIR USO DE PIEZAS CONTRARIAS
#Falta revisar que antes de agregar el mlN de cada X marcada al lado de ref esa casilla este en el tablero (es un if por cada caso para ver si no se va de bounds)
#5. Posible error de indice numerico de ref en vez de letra