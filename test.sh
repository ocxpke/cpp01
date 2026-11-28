#!/bin/bash
# Bateria de tests para C++ Module 01
# Uso: desde la raiz del repo (donde estan ex00..ex06):
#   bash test_cpp01.sh 2>&1 | tee resultado.txt

ROOT=$(pwd)
TMP=$(mktemp -d)
PASS=0
FAIL=0

ok()   { echo "  [OK] $1"; PASS=$((PASS+1)); }
ko()   { echo "  [KO] $1"; FAIL=$((FAIL+1)); }
sec()  { echo; echo "################ $1 ################"; }
sub()  { echo "--- $1"; }

vg() {
	# $1 nombre, resto: comando
	local name=$1; shift
	local log="$TMP/vg.log"
	valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all \
		--error-exitcode=42 "$@" >/dev/null 2>"$log"
	if [ $? -eq 42 ]; then
		ko "valgrind $name"; grep -E "definitely|indirectly|ERROR SUMMARY|Invalid" "$log" | head -5
	else
		ok "valgrind $name ($(grep -o 'total heap usage: [0-9,]* allocs, [0-9,]* frees' "$log"))"
	fi
}

check_eq() {
	# $1 nombre, $2 obtenido, $3 esperado
	if [ "$2" == "$3" ]; then ok "$1"; else
		ko "$1"; echo "    obtenido: $(printf '%q' "$2")"; echo "    esperado: $(printf '%q' "$3")"; fi
}

check_has() {
	# $1 nombre, $2 texto, $3 patron
	if echo "$2" | grep -qE -- "$3"; then ok "$1"; else ko "$1 (no contiene: $3)"; fi
}

########################################################################
sec "INFO"
echo "Fecha: $(date)"
echo "Compilador: $(c++ --version | head -1)"
echo "Git: $(git log --oneline 2>/dev/null | head -1)"
git status --short 2>/dev/null | head

########################################################################
sec "ARCHIVOS OBLIGATORIOS"
req() {
	local dir=$1; shift
	for f in "$@"; do
		if [ -f "$dir/$f" ]; then ok "$dir/$f"; else ko "$dir/$f FALTA"; fi
	done
}
req ex00 Makefile main.cpp Zombie.hpp Zombie.cpp newZombie.cpp randomChump.cpp
req ex01 Makefile main.cpp Zombie.hpp Zombie.cpp zombieHorde.cpp
req ex02 Makefile main.cpp
req ex03 Makefile main.cpp Weapon.hpp Weapon.cpp HumanA.hpp HumanA.cpp HumanB.hpp HumanB.cpp
req ex04 Makefile main.cpp
req ex05 Makefile main.cpp Harl.hpp Harl.cpp
req ex06 Makefile main.cpp Harl.hpp Harl.cpp
sub "Archivos que no deberian estar"
EXTRA=$(find . -path ./.git -prune -o -type f \( -name "*.o" -o -name "*.pdf" -o -perm -u+x ! -name "*.sh" \) -print)
if [ -z "$EXTRA" ]; then ok "sin .o, binarios ni pdf"; else ko "sobran archivos:"; echo "$EXTRA"; fi

########################################################################
sec "REGLAS GENERALES"
sub "Funciones / palabras prohibidas"
BAD=$(grep -nE "printf|[^a-z]alloc\(|[^a-z]free\(|using +namespace|friend|fopen|fread|fwrite|fclose" ex0*/*.cpp ex0*/*.hpp)
if [ -z "$BAD" ]; then ok "nada prohibido"; else ko "prohibido encontrado:"; echo "$BAD"; fi
BAD=$(grep -n "\.replace(" ex04/*.cpp ex04/*.hpp 2>/dev/null)
if [ -z "$BAD" ]; then ok "ex04 sin std::string::replace"; else ko "ex04 usa replace: $BAD"; fi
sub "STL (contenedores / algorithm)"
BAD=$(grep -nE "#include *<(vector|list|map|set|deque|stack|queue|algorithm)>" ex0*/*.cpp ex0*/*.hpp)
if [ -z "$BAD" ]; then ok "sin STL"; else ko "STL: $BAD"; fi
sub "Include guards en todos los headers"
for h in ex0*/*.hpp; do
	if grep -qE "^#\s*ifndef" "$h" && grep -qE "^#\s*define" "$h" && grep -qE "^#\s*endif" "$h"; then
		ok "$h"; else ko "$h sin include guards"; fi
done
sub "Sin implementaciones en headers (busca llaves de funciones)"
for h in ex0*/*.hpp; do
	if grep -qE "\)\s*(const)?\s*\{" "$h"; then ko "$h tiene codigo"; else ok "$h"; fi
done
sub "Headers independientes (cada .hpp compila solo)"
for h in ex0*/*.hpp; do
	if echo "#include \"$ROOT/$h\"" | c++ -Wall -Wextra -Werror -std=c++98 -x c++ -fsyntax-only - 2>/dev/null; then
		ok "$h"; else ko "$h no compila solo"; fi
done

########################################################################
sec "MAKEFILES"
for d in ex0*; do
	sub "$d"
	M="$d/Makefile"
	for r in 'NAME' 'all:' 'clean:' 'fclean:' 're:'; do
		grep -q "^$r\|^$r *=" "$M" && ok "regla/variable $r" || ko "falta $r en $M"
	done
	grep -q -- "-Wall" "$M" && grep -q -- "-Wextra" "$M" && grep -q -- "-Werror" "$M" && ok "flags -Wall -Wextra -Werror" || ko "faltan flags"
	grep -q -- "-std=c++98" "$M" && ok "-std=c++98" || ko "falta -std=c++98"
	make -s -C "$d" fclean >/dev/null 2>&1
	OUT=$(make -C "$d" 2>&1); [ $? -eq 0 ] && ok "make compila" || { ko "make falla"; echo "$OUT" | tail -5; }
	OUT=$(make -C "$d" 2>&1); echo "$OUT" | grep -qE "Nothing to be done|up to date" && ok "no relink" || ko "relink: $OUT"
	touch "$d"/main.cpp; OUT=$(make -C "$d" 2>&1); echo "$OUT" | grep -q "main.cpp" && ok "recompila al tocar main.cpp" || ko "no recompila tras cambio"
	make -s -C "$d" clean; ls "$d"/*.o >/dev/null 2>&1 && ko "clean deja .o" || ok "clean borra .o"
	make -s -C "$d" all >/dev/null 2>&1
	make -s -C "$d" fclean; [ -z "$(find "$d" -maxdepth 1 -type f -perm -u+x)" ] && ok "fclean borra binario" || ko "fclean deja binario"
	make -s -C "$d" re >/dev/null 2>&1 && ok "make re" || ko "make re falla"
done
sub "Compilacion con g++ y clang++ (si existen)"
for cc in g++ clang++; do
	if command -v $cc >/dev/null; then
		for d in ex0*; do
			(cd $d && $cc -Wall -Wextra -Werror -std=c++98 *.cpp -o "$TMP/bin_$cc" 2>"$TMP/cc.log") \
				&& ok "$cc $d" || { ko "$cc $d"; head -5 "$TMP/cc.log"; }
		done
	else echo "  ($cc no instalado)"; fi
done

########################################################################
sec "EX00 - BraiiiiiiinnnzzzZ"
B=$(find ex00 -maxdepth 1 -type f -perm -u+x | head -1)
OUT=$(./$B)
echo "$OUT"
check_has "announce con formato exacto" "$OUT" ": BraiiiiiiinnnzzzZ\.\.\.$"
N_ANN=$(echo "$OUT" | grep -c "BraiiiiiiinnnzzzZ")
N_DES=$(echo "$OUT" | grep -ciE "destr|die|dead")
echo "  announces: $N_ANN, mensajes de destructor: $N_DES"
sub "Codigo"
grep -q "new Zombie" ex00/newZombie.cpp && ok "newZombie usa new (heap)" || ko "newZombie no usa new"
grep -q "new " ex00/randomChump.cpp && ko "randomChump usa new (deberia ser stack)" || ok "randomChump en stack"
grep -q "delete" ex00/main.cpp && ok "main hace delete del zombie de newZombie" || ko "main no hace delete"
vg "ex00" ./$B

########################################################################
sec "EX01 - Moar brainz!"
B=$(find ex01 -maxdepth 1 -type f -perm -u+x | head -1)
OUT=$(./$B)
echo "$OUT"
check_has "announce con formato exacto" "$OUT" ": BraiiiiiiinnnzzzZ\.\.\.$"
sub "Codigo"
grep -qE "new Zombie\[" ex01/zombieHorde.cpp && ok "una sola asignacion new Zombie[N]" || ko "no usa new Zombie[N]"
[ "$(grep -vE '^\s*(\*|//|/\*)' ex01/zombieHorde.cpp | grep -c 'new ')" -eq 1 ] && ok "un unico new en zombieHorde" || ko "mas de un new en zombieHorde"
grep -q "delete\s*\[\]" ex01/main.cpp && ok "main libera con delete[]" || ko "main no usa delete[]"
sub "Test con N distintos (programa temporal)"
cat > "$TMP/horde_test.cpp" <<'EOF'
#include "Zombie.hpp"
#include <iostream>
#include <cstdlib>
int main(int ac, char **av)
{
	int n = (ac > 1) ? std::atoi(av[1]) : 3;
	Zombie *h = zombieHorde(n, "Tester");
	if (h == NULL) { std::cout << "NULL" << std::endl; return 0; }
	for (int i = 0; i < n; i++) h[i].announce();
	delete[] h;
	return 0;
}
EOF
if (cd ex01 && c++ -Wall -Wextra -Werror -std=c++98 -I. "$TMP/horde_test.cpp" Zombie.cpp zombieHorde.cpp -o "$TMP/horde" 2>"$TMP/h.log"); then
	for n in 1 3 10 100; do
		C=$("$TMP/horde" $n | grep -c "Tester: BraiiiiiiinnnzzzZ")
		check_eq "N=$n -> $n announces" "$C" "$n"
		vg "horde N=$n" "$TMP/horde" $n
	done
	for n in 0 -5; do
		R=$("$TMP/horde" $n 2>&1 | head -1)
		echo "  N=$n -> $R"
		vg "horde N=$n" "$TMP/horde" $n
	done
else ko "no compila el test de la horda"; cat "$TMP/h.log" | head -5; fi
vg "ex01" ./$B

########################################################################
sec "EX02 - HI THIS IS BRAIN"
B=$(find ex02 -maxdepth 1 -type f -perm -u+x | head -1)
OUT=$(./$B)
echo "$OUT"
ADDRS=$(echo "$OUT" | grep -oE "0x[0-9a-f]+" | sort -u | wc -l)
check_eq "las 3 direcciones son la misma" "$ADDRS" "1"
VALS=$(echo "$OUT" | grep -c "HI THIS IS BRAIN")
check_eq "los 3 valores son HI THIS IS BRAIN" "$VALS" "3"
grep -q "std::string\s*\*\s*stringPTR" ex02/main.cpp && ok "stringPTR declarado" || ko "falta stringPTR"
grep -q "std::string\s*&\s*stringREF" ex02/main.cpp && ok "stringREF declarado" || ko "falta stringREF"
vg "ex02" ./$B

########################################################################
sec "EX03 - Unnecessary violence"
B=$(find ex03 -maxdepth 1 -type f -perm -u+x | head -1)
OUT=$(./$B)
echo "$OUT"
EXP=$'Bob attacks with their crude spiked club\nBob attacks with their some other type of club\nJim attacks with their crude spiked club\nJim attacks with their some other type of club'
check_eq "salida del subject (primeras 4 lineas)" "$(echo "$OUT" | head -4)" "$EXP"
sub "Codigo"
grep -qE "Weapon\s*&\s*_?[a-zA-Z]*;" ex03/HumanA.hpp && ok "HumanA guarda una referencia" || ko "HumanA no usa referencia"
grep -qE "Weapon\s*\*\s*_?[a-zA-Z]*;" ex03/HumanB.hpp && ok "HumanB guarda un puntero" || ko "HumanB no usa puntero"
grep -qE "const std::string\s*&\s*getType" ex03/Weapon.hpp && ok "getType devuelve const std::string&" || ko "getType no devuelve const ref"
sub "HumanB sin arma (programa temporal)"
cat > "$TMP/humanb_test.cpp" <<'EOF'
#include "HumanB.hpp"
int main(void)
{
	HumanB tom("Tom");
	tom.attack();
	Weapon w("stick");
	tom.setWeapon(w);
	tom.attack();
	w.setType("big stick");
	tom.attack();
	return 0;
}
EOF
if (cd ex03 && c++ -Wall -Wextra -Werror -std=c++98 -I. "$TMP/humanb_test.cpp" Weapon.cpp HumanB.cpp -o "$TMP/hb" 2>"$TMP/hb.log"); then
	OUT=$("$TMP/hb" 2>&1); RC=$?
	echo "$OUT"
	check_eq "HumanB sin arma no crashea" "$RC" "0"
	check_has "HumanB con arma ataca" "$OUT" "Tom attacks with their stick"
	check_has "HumanB ve el cambio de tipo" "$OUT" "Tom attacks with their big stick"
	vg "HumanB test" "$TMP/hb"
else ko "no compila el test de HumanB"; head -5 "$TMP/hb.log"; fi
vg "ex03" ./$B

########################################################################
sec "EX04 - Sed is for losers"
B=$(cd ex04 && find . -maxdepth 1 -type f -perm -u+x | head -1)
B="$ROOT/ex04/${B#./}"
sub "Tests propios (tests/run_tests.sh)"
if [ -f ex04/tests/run_tests.sh ]; then
	[ -x ex04/tests/run_tests.sh ] && ok "run_tests.sh es ejecutable" || ko "run_tests.sh sin permiso de ejecucion"
	(cd ex04 && bash tests/run_tests.sh)
else ko "no hay tests propios"; fi

sub "Casos extra"
cd "$TMP"
t4() {
	# $1 nombre, $2 contenido, $3 s1, $4 s2, $5 esperado
	printf '%s' "$2" > in.txt
	rm -f in.txt.replace
	"$B" in.txt "$3" "$4" >/dev/null 2>&1
	if [ ! -f in.txt.replace ]; then ko "$1 (no crea .replace)"; return; fi
	check_eq "$1" "$(cat in.txt.replace; echo x)" "$5"x
	check_eq "$1: original intacto" "$(cat in.txt; echo x)" "$2"x
}
t4 "reemplazo simple"            $'hello world\n'            "world" "42"    $'hello 42\n'
t4 "varias por linea"            $'aXbXc\n'                  "X"     "--"    $'a--b--c\n'
t4 "s2 vacio borra"              $'a-b-c\n'                  "-"     ""      $'abc\n'
t4 "s2 contiene s1"              $'ab\n'                     "a"     "aaa"   $'aaab\n'
t4 "coincidencias solapadas"     $'aaaaa\n'                  "aa"    "b"     $'bba\n'
t4 "s1 igual a s2"               $'same same\n'              "same"  "same"  $'same same\n'
t4 "s1 con espacios"             $'hola que tal\n'           "a q"   "_"     $'hol_ue tal\n'
t4 "s1 con salto de linea"       $'l1\nl2\nl3\n'             $'\n'   "|"     'l1|l2|l3|'
t4 "s1 multilinea"               $'ab\ncd\n'                 $'b\nc' "X"     $'aXd\n'
t4 "sin salto final"             'no newline at end'         "end"   "END"   'no newline at END'
t4 "sin coincidencias"           $'nothing here\n'           "zzz"   "y"     $'nothing here\n'
t4 "archivo vacio"               ''                          "a"     "b"     ''
t4 "lineas vacias"               $'\n\n\nx\n\n'              "x"     "y"     $'\n\n\ny\n\n'
t4 "caracteres especiales"       $'$HOME * ? [a] \\n\n'      '*'     'STAR'  $'$HOME STAR ? [a] \\n\n'
t4 "s1 al inicio y al final"     $'abcab'                    "ab"    "Z"     $'ZcZ'
t4 "texto entero es s1"          'word'                      "word"  "x"     'x'
t4 "mayusculas distintas"        $'Word word WORD\n'         "word"  "x"     $'Word x WORD\n'
t4 "tabs"                        $'a\tb\tc\n'                $'\t'   " "     $'a b c\n'
printf 'linea %s con patron\n' $(seq 1 20000) > big.txt
"$B" big.txt patron PATRON >/dev/null 2>&1
check_eq "archivo grande (20000 lineas)" "$(grep -c PATRON big.txt.replace)" "20000"
printf 'x' > over.txt; printf 'viejo' > over.txt.replace
"$B" over.txt x y >/dev/null 2>&1
check_eq ".replace existente se sobrescribe" "$(cat over.txt.replace)" "y"
printf 'a b\n' > "con espacio.txt"
"$B" "con espacio.txt" a z >/dev/null 2>&1
[ -f "con espacio.txt.replace" ] && ok "nombre de archivo con espacios" || ko "nombre con espacios"

sub "Errores (deben fallar y no crear .replace)"
e4() {
	local name=$1; shift
	rm -f *.replace
	OUT=$("$B" "$@" 2>&1); RC=$?
	if [ $RC -ne 0 ]; then ok "$name (rc=$RC: $(echo "$OUT" | head -1))"; else ko "$name (rc=0)"; fi
}
printf 'abc\n' > in.txt
e4 "sin argumentos"
e4 "1 argumento"              in.txt
e4 "2 argumentos"             in.txt a
e4 "4 argumentos"             in.txt a b c
e4 "archivo inexistente"      noexiste.txt a b
e4 "s1 vacio"                 in.txt "" b
mkdir -p dir.txt
e4 "un directorio"            dir.txt a b
printf 'abc\n' > noread.txt; chmod 000 noread.txt
if [ "$(id -u)" -ne 0 ]; then e4 "sin permiso de lectura" noread.txt a b; fi
chmod 644 noread.txt
mkdir -p ro && printf 'abc\n' > ro/f.txt && chmod 555 ro
if [ "$(id -u)" -ne 0 ]; then e4 "carpeta sin permiso de escritura" ro/f.txt a b; fi
chmod 755 ro
printf 'abc\n' > in.txt
vg "ex04 normal"       "$B" in.txt b X
vg "ex04 s1 vacio"     "$B" in.txt "" X
vg "ex04 inexistente"  "$B" noexiste.txt a b
vg "ex04 archivo grande" "$B" big.txt patron PATRON
cd "$ROOT"
rm -f ex04/tests/*.replace

########################################################################
sec "EX05 - Harl 2.0"
B=$(find ex05 -maxdepth 1 -type f -perm -u+x | head -1)
OUT=$(./$B)
echo "$OUT"
sub "Codigo"
grep -qE "\(\s*this\s*->\*|\.\*" ex05/Harl.cpp && ok "usa punteros a funciones miembro" || ko "no usa punteros a miembro"
grep -qE "Harl::\*" ex05/Harl.cpp ex05/Harl.hpp && ok "declara puntero a miembro (Harl::*)" || ko "no declara Harl::*"
NIF=$(grep -cE "^\s*(else\s+)?if\s*\(" ex05/Harl.cpp)
[ "$NIF" -le 1 ] && ok "sin bosque de if/else ($NIF if)" || ko "demasiados if ($NIF)"
grep -qE "private:" ex05/Harl.hpp && ok "tiene seccion private" || ko "falta private"
for f in debug info warning error; do
	awk '/private:/{p=1} /public:/{p=0} p' ex05/Harl.hpp | grep -q "$f" && ok "$f es privada" || ko "$f no es privada"
done
sub "complain con cada nivel (programa temporal)"
cat > "$TMP/harl_test.cpp" <<'EOF'
#include "Harl.hpp"
#include <iostream>
int main(int ac, char **av)
{
	Harl h;
	for (int i = 1; i < ac; i++)
	{
		std::cout << "<" << av[i] << ">" << std::endl;
		h.complain(av[i]);
	}
	return 0;
}
EOF
if (cd ex05 && c++ -Wall -Wextra -Werror -std=c++98 -I. "$TMP/harl_test.cpp" Harl.cpp -o "$TMP/harl" 2>"$TMP/harl.log"); then
	"$TMP/harl" DEBUG INFO WARNING ERROR debug "" "DEBUG " XYZ
	check_has "DEBUG"   "$("$TMP/harl" DEBUG)"   "7XL-double-cheese-triple-pickle-special-ketchup"
	check_has "INFO"    "$("$TMP/harl" INFO)"    "adding extra bacon costs more money"
	check_has "WARNING" "$("$TMP/harl" WARNING)" "extra bacon for free"
	check_has "ERROR"   "$("$TMP/harl" ERROR)"   "speak to the manager"
	vg "harl todos los niveles" "$TMP/harl" DEBUG INFO WARNING ERROR xyz
else ko "no compila el test de Harl"; head -5 "$TMP/harl.log"; fi
vg "ex05" ./$B

########################################################################
sec "EX06 - Harl filter"
B=$(find ex06 -maxdepth 1 -type f -perm -u+x | head -1)
[ "$(basename "$B")" == "harlFilter" ] && ok "ejecutable se llama harlFilter" || ko "ejecutable: $(basename "$B") (debe ser harlFilter)"
grep -q "switch" ex06/Harl.cpp ex06/main.cpp && ok "usa switch" || ko "no usa switch"
for lv in DEBUG INFO WARNING ERROR; do
	sub "./harlFilter $lv"
	OUT=$(./$B $lv)
	echo "$OUT"
done
check_eq "DEBUG muestra 4 niveles"   "$(./$B DEBUG   | grep -c '^\[ ')" "4"
check_eq "INFO muestra 3 niveles"    "$(./$B INFO    | grep -c '^\[ ')" "3"
check_eq "WARNING muestra 2 niveles" "$(./$B WARNING | grep -c '^\[ ')" "2"
check_eq "ERROR muestra 1 nivel"     "$(./$B ERROR   | grep -c '^\[ ')" "1"
check_eq "orden de DEBUG" "$(./$B DEBUG | grep '^\[ ' | tr '\n' ' ')" "[ DEBUG ] [ INFO ] [ WARNING ] [ ERROR ] "
EXP=$'[ WARNING ]\nI think I deserve to have some extra bacon for free.\nI\'ve been coming for years, whereas you started working here just last month.\n\n[ ERROR ]\nThis is unacceptable! I want to speak to the manager now.\n\n'
check_eq "ejemplo del subject (WARNING) exacto" "$(./$B WARNING; echo x)" "$EXP"x
INS="[ Probably complaining about insignificant problems ]"
for bad in "I am not sure how tired I am today..." "debug" "" "WARNINGS" " ERROR" "42"; do
	check_eq "nivel invalido '$bad'" "$(./$B "$bad")" "$INS"
done
sub "Argumentos incorrectos"
./$B >/dev/null 2>&1; RC=$?; echo "  sin argumentos -> rc=$RC: $(./$B 2>&1 | head -1)"
./$B A B >/dev/null 2>&1; RC=$?; echo "  2 argumentos  -> rc=$RC: $(./$B A B 2>&1 | head -1)"
vg "ex06 DEBUG" ./$B DEBUG
vg "ex06 invalido" ./$B nada
vg "ex06 sin args" ./$B

########################################################################
sec "LIMPIEZA"
for d in ex0*; do make -s -C $d fclean; done
rm -rf "$TMP"
git status --short 2>/dev/null
echo
echo "================================================"
echo "  TOTAL:  OK=$PASS   KO=$FAIL"
echo "================================================"
