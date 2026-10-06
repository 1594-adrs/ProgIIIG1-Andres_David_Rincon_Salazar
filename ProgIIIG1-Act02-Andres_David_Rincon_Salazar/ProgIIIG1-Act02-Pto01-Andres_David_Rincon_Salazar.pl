/*
===============================================================================
Publication Date: 2026-10-02
Publication Time: 23:45
Code Version: 1.0
Author: Ing(c) Andres David Rincon Salazar
Programming Language: Prolog
Language Version: ISO/IEC 13211-1 (SWI-Prolog 10.0.2)
Compiler: SWI-Prolog 10.0.2
Operating System: Windows 11 - 24H2
Presented to: Ramiro Andres Barrios Valencia
University: Universidad Tecnologica de Pereira
Program: Ingenieria de Sistemas y Computacion

Program Description:
Koenigsberg bridges problem. The four land masses are the vertices of a
multigraph and the seven bridges are its edges. The question is whether a
walk exists that crosses every bridge exactly once and returns to the
starting point (Euler circuit). It is answered in two ways:
  1. Euler's theorem: a connected multigraph has an Euler circuit if and
     only if every vertex has even degree.
  2. Exhaustive search by backtracking: the program tries every walk and
     fails when none closes using all the bridges.
Validation queries are included at the end of the file.

Predicates description:
- zona(Zona): (fact) land mass (vertex).
- puente(Id, A, B): (fact) bridge Id joins land masses A and B.
- cruce(Id, Desde, Hasta): (rule) bridge crossed in either direction.
- grado(Zona, Grado): (rule) number of bridges touching Zona.
- grado_par(Zona): (rule) Zona has even degree.
- circuito_euler_teorema: (rule) every zone has even degree.
- paseo(Inicio, Pasos): (rule) closed walk from Inicio using each bridge
  exactly once, found by backtracking. Pasos = [paso(Id, De, A), ...].
- hay_paseo: (rule) some starting zone admits such a walk.

Warnings (Salvedades):
- The slide gives no figure, so the bridge layout is taken from the
  historical map: norte and sur are the river banks, kneiphof and este
  (Lomse) are the two islands; 2 bridges norte-kneiphof, 2 sur-kneiphof,
  and 1 each for norte-este, sur-este and kneiphof-este.
- The two parallel bridges between norte-kneiphof and sur-kneiphof are
  distinct facts (b1/b2 and b3/b4); that is why the graph is a multigraph.
- circuito_euler_teorema/0 only checks the degrees; connectivity of the
  graph is assumed (it holds for Koenigsberg), not verified by the program.
- paseo/2 has no solution for this graph; the search is exhaustive but small
  (7 bridges), so it ends quickly.
===============================================================================
*/

%===============================================================================
% FACTS: land masses (vertices)
%===============================================================================
zona(norte).
zona(sur).
zona(kneiphof).
zona(este).

%===============================================================================
% FACTS: the seven bridges (edges), puente(Id, ZonaA, ZonaB)
%===============================================================================
puente(b1, norte, kneiphof).
puente(b2, norte, kneiphof).
puente(b3, sur,   kneiphof).
puente(b4, sur,   kneiphof).
puente(b5, norte, este).
puente(b6, sur,   este).
puente(b7, kneiphof, este).

%===============================================================================
% RULE: a bridge can be crossed in both directions
%===============================================================================
cruce(Id, Desde, Hasta) :- puente(Id, Desde, Hasta).
cruce(Id, Desde, Hasta) :- puente(Id, Hasta, Desde).

%===============================================================================
% RULES: degree of a vertex and Euler's theorem
%===============================================================================
grado(Zona, Grado) :-
    zona(Zona),
    findall(Id, cruce(Id, Zona, _), Puentes),
    length(Puentes, Grado).

grado_par(Zona) :-
    grado(Zona, Grado),
    0 is Grado mod 2.

% The graph is connected, so the theorem reduces to "all degrees are even".
circuito_euler_teorema :-
    forall(zona(Zona), grado_par(Zona)).

%===============================================================================
% RULES: exhaustive search by backtracking
% caminar/5 crosses an unused bridge at each step; when it chooses a dead
% end, Prolog backtracks and tries the next bridge.
%===============================================================================
paseo(Inicio, Pasos) :-
    zona(Inicio),
    aggregate_all(count, puente(_, _, _), Total),
    caminar(Inicio, Inicio, Total, [], PasosInv),
    reverse(PasosInv, Pasos).

% Base case: back at the start with every bridge used.
caminar(Fin, Fin, Total, Usados, Usados) :-
    length(Usados, Total).
caminar(Actual, Fin, Total, Usados, Resultado) :-
    cruce(Id, Actual, Siguiente),
    \+ memberchk(paso(Id, _, _), Usados),
    caminar(Siguiente, Fin, Total, [paso(Id, Actual, Siguiente)|Usados], Resultado).

hay_paseo :-
    paseo(_, _), !.

/*
===============================================================================
Validation queries
===============================================================================
?- grado(norte, G).
G = 3.
?- grado(sur, G).
G = 3.
?- grado(kneiphof, G).
G = 5.
?- grado(este, G).
G = 3.
?- grado_par(kneiphof).
false.
?- circuito_euler_teorema.
false.
?- paseo(norte, Pasos).
false.
?- paseo(kneiphof, Pasos).
false.
?- hay_paseo.
false.
===============================================================================
*/
