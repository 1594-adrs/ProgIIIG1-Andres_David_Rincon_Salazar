/*
===============================================================================
Publication Date: 2026-10-10
Publication Time: 21:45
Code Version: 1.0
Author: Ing(c) Andres David Rincon Salazar
Programming Language: Prolog
Language Version: ISO/IEC 13211-1 (SWI-Prolog 10.0.2)
Compiler: SWI-Prolog 10.0.2
Operating System: Windows 11 - 24H2
Presented to: Ramiro Andres Barrios Valencia
University: Universidad Tecnologica de Pereira
Program: Ingenieria de Sistemas y Computacion
Based on: ProgIIIG1-Act02-Pto03 (Canadian cities, one fact per edge)

Program Description:
Directed weighted graph of Canadian cities (Vancouver, Edmonton, Calgary,
Saskatoon, Regina, Winnipeg) rewritten with structures and lists. The
one-fact-per-edge model arista(Origen, Destino, Costo) of Activity 2 is
replaced by an adjacency list per city:
    nodo(Ciudad, [enlace(Destino, Costo), ...])
The structure enlace/2 holds a neighbour and the cost of reaching it; the
list holds all the edges that leave Ciudad. arista/3 disappears: every rule
now reads the edges by traversing those lists with member/2.
The program still answers the same questions of the slides:
  - Is there a connection between Saskatoon and Vancouver?
  - Which nodes is Regina connected to, and at what cost?
  - Does a node have edges?
  - What is the cost of going from X to Z passing through Y?
  - Is it possible to travel from Edmonton to Calgary?
The last question needs recursion. A naive version (ruta_ingenua/2) shows
how SLD resolution loops on the cycle edmonton -> saskatoon -> calgary ->
edmonton, and a safe version with a list of visited nodes (hay_camino/2)
fixes it. Validation queries are included at the end of the file.

Predicates description:
- nodo(Ciudad, Enlaces): (fact) Ciudad and the list of its outgoing edges.
- conexion_directa(A, B, Costo): (rule) B is in the Enlaces list of A.
- vecinos_de(Nodo, Vecinos): (rule) list of the cities Nodo has an edge to.
- conectado_con(Nodo, Otro, Costo, Sentido): (rule) neighbours of Nodo;
  Sentido is salida (Nodo -> Otro) or entrada (Otro -> Nodo).
- tiene_aristas(Nodo): (rule) Nodo has at least one incoming/outgoing edge.
- camino(Origen, Destino, Nodos, Costo): (rule) simple directed path.
- hay_camino(Origen, Destino): (rule) safe reachability.
- costo_via(X, Y, Z, Costo): (rule) cost of a path X -> Z that passes by Y.
- ruta_ingenua(Origen, Destino): (rule) naive reachability, may not end.

Warnings (Salvedades):
- Edges are directed: Vancouver reaches Saskatoon but not the other way.
- Costs are the numbers written on the edges of the slide.
- Winnipeg has no outgoing edge, so its list is empty: nodo(winnipeg, []).
  Every city must have its own nodo/2 fact, even with an empty list: a
  city that only appears as a destination inside another list is not
  seen as an origin. A city with no nodo/2 fact (Toronto) has no edges.
- costo_via/4 considers simple paths X -> Z that contain Y as an
  intermediate node; there can be several answers (one per path).
- ruta_ingenua/2 is only a didactic example: it answers true for
  reachable pairs but, because of the cycle, keeps producing more true
  answers forever (one per lap) and, for unreachable pairs, keeps looping
  until it overflows the stack (about one minute with the default 1 GB
  stack limit of SWI-Prolog). Do not use it as a solution.
===============================================================================
*/

%===============================================================================
% FACTS: adjacency lists, nodo(Ciudad, [enlace(Destino, Costo), ...])
%===============================================================================
nodo(vancouver, [enlace(edmonton, 16), enlace(calgary, 13)]).
nodo(edmonton,  [enlace(saskatoon, 12)]).
nodo(calgary,   [enlace(edmonton, 4), enlace(regina, 14)]).
nodo(saskatoon, [enlace(calgary, 9), enlace(winnipeg, 20)]).
nodo(regina,    [enlace(saskatoon, 7), enlace(winnipeg, 4)]).
nodo(winnipeg,  []).

%===============================================================================
% RULES: direct connections (questions 1 and 2 of the slides)
%===============================================================================
conexion_directa(A, B, Costo) :-
    nodo(A, Enlaces),
    member(enlace(B, Costo), Enlaces).

vecinos_de(Nodo, Vecinos) :-
    nodo(Nodo, Enlaces),
    findall(Vecino, member(enlace(Vecino, _), Enlaces), Vecinos).

conectado_con(Nodo, Otro, Costo, salida)  :- conexion_directa(Nodo, Otro, Costo).
conectado_con(Nodo, Otro, Costo, entrada) :- conexion_directa(Otro, Nodo, Costo).

%===============================================================================
% RULE: a node has edges if some edge leaves or reaches it
%===============================================================================
tiene_aristas(Nodo) :-
    ( conexion_directa(Nodo, _, _) ; conexion_directa(_, Nodo, _) ), !.

%===============================================================================
% RULES: safe paths (visited list) -> Edmonton to Calgary question
%===============================================================================
camino(Origen, Destino, Nodos, Costo) :-
    recorrer(Origen, Destino, [Origen], NodosInv, Costo),
    reverse(NodosInv, Nodos).

recorrer(Destino, Destino, Visitados, Visitados, 0).
recorrer(Actual, Destino, Visitados, Ruta, Costo) :-
    conexion_directa(Actual, Siguiente, C1),
    \+ memberchk(Siguiente, Visitados),
    recorrer(Siguiente, Destino, [Siguiente|Visitados], Ruta, C2),
    Costo is C1 + C2.

hay_camino(Origen, Destino) :-
    camino(Origen, Destino, _, _), !.

%===============================================================================
% RULE: cost from X to Z passing through Y (Y is neither X nor Z)
%===============================================================================
costo_via(X, Y, Z, Costo) :-
    camino(X, Z, Nodos, Costo),
    Y \== X,
    Y \== Z,
    memberchk(Y, Nodos).

%===============================================================================
% DIDACTIC RULE: naive reachability (no visited list)
%
% SLD tree for ?- ruta_ingenua(edmonton, calgary).
%
%   ruta_ingenua(edmonton, calgary)
%     |-- clause 1: conexion_directa(edmonton, calgary, _)       FAIL
%     |-- clause 2: conexion_directa(edmonton, Z, _)  Z = saskatoon
%           ruta_ingenua(saskatoon, calgary)
%             |-- clause 1: conexion_directa(saskatoon, calgary, _)  SUCCESS (true)
%             |-- clause 2 (on backtracking): Z = calgary
%                   ruta_ingenua(calgary, calgary)
%                     |-- clause 1: FAIL
%                     |-- clause 2: Z = edmonton -> ruta_ingenua(edmonton, calgary)
%                                   ... the initial goal again: INFINITE LOOP
%===============================================================================
ruta_ingenua(Origen, Destino) :- conexion_directa(Origen, Destino, _).
ruta_ingenua(Origen, Destino) :-
    conexion_directa(Origen, Intermedio, _),
    ruta_ingenua(Intermedio, Destino).

/*
===============================================================================
Validation queries
===============================================================================
% Question 1: connection between Saskatoon and Vancouver
?- conexion_directa(saskatoon, vancouver, C).
false.
?- hay_camino(saskatoon, vancouver).
false.
?- hay_camino(vancouver, saskatoon).
true.

% Question 2: nodes connected to Regina and cost of each connection
?- conectado_con(regina, Otro, Costo, Sentido).
Otro = saskatoon, Costo = 7,  Sentido = salida ;
Otro = winnipeg,  Costo = 4,  Sentido = salida ;
Otro = calgary,   Costo = 14, Sentido = entrada.
?- vecinos_de(regina, Vecinos).
Vecinos = [saskatoon, winnipeg].

% Rule: node has edges
?- tiene_aristas(regina).
true.
?- tiene_aristas(toronto).
false.

% Rule: cost from X to Z passing through Y
?- costo_via(vancouver, calgary, winnipeg, C).
C = 55 ;
C = 49 ;
C = 54 ;
C = 31 ;
false.
?- costo_via(vancouver, regina, winnipeg, C).
C = 55 ;
C = 54 ;
C = 31 ;
false.
?- costo_via(winnipeg, regina, vancouver, C).
false.

% Most interesting question: Edmonton -> Calgary
?- hay_camino(edmonton, calgary).
true.
?- camino(edmonton, calgary, Nodos, Costo).
Nodos = [edmonton, saskatoon, calgary],
Costo = 21 ;
false.
?- ruta_ingenua(edmonton, calgary).
true ;
true ;    % ... one more true per lap around the cycle: never ends (see SLD tree above)
?- ruta_ingenua(saskatoon, vancouver).
ERROR: Stack limit (1.0Gb) exceeded.    % only after about one minute
===============================================================================
*/
