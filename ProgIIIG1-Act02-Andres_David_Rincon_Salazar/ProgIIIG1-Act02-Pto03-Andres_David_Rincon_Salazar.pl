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
Directed weighted graph of Canadian cities (Vancouver, Edmonton, Calgary,
Saskatoon, Regina, Winnipeg). Answers the questions of the slides:
  - Is there a connection between Saskatoon and Vancouver?
  - Which nodes is Regina connected to, and at what cost?
  - Does a node have edges?
  - What is the cost of going from X to Z passing through Y?
  - Is it possible to travel from Edmonton to Calgary?
The last question needs recursion. A naive version (ruta_ingenua/2) is
included to show how SLD resolution loops on the cycle
edmonton -> saskatoon -> calgary -> edmonton (the first cycle reached with
the clause order of the facts), and a safe version with a list of visited
nodes (hay_camino/2) fixes it. Validation queries are
included at the end of the file.

Predicates description:
- arista(Origen, Destino, Costo): (fact) directed edge with its cost.
- conexion_directa(A, B, Costo): (rule) edge from A to B.
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
% FACTS: directed edges, arista(Origen, Destino, Costo)
%===============================================================================
arista(vancouver, edmonton,  16).
arista(vancouver, calgary,   13).
arista(edmonton,  saskatoon, 12).
arista(calgary,   edmonton,   4).
arista(calgary,   regina,    14).
arista(saskatoon, calgary,    9).
arista(saskatoon, winnipeg,  20).
arista(regina,    saskatoon,  7).
arista(regina,    winnipeg,   4).

%===============================================================================
% RULES: direct connections (questions 1 and 2 of the slides)
%===============================================================================
conexion_directa(A, B, Costo) :- arista(A, B, Costo).

conectado_con(Nodo, Otro, Costo, salida)  :- arista(Nodo, Otro, Costo).
conectado_con(Nodo, Otro, Costo, entrada) :- arista(Otro, Nodo, Costo).

%===============================================================================
% RULE: a node has edges if some edge leaves or reaches it
%===============================================================================
tiene_aristas(Nodo) :-
    ( arista(Nodo, _, _) ; arista(_, Nodo, _) ), !.

%===============================================================================
% RULES: safe paths (visited list) -> Edmonton to Calgary question
%===============================================================================
camino(Origen, Destino, Nodos, Costo) :-
    recorrer(Origen, Destino, [Origen], NodosInv, Costo),
    reverse(NodosInv, Nodos).

recorrer(Destino, Destino, Visitados, Visitados, 0).
recorrer(Actual, Destino, Visitados, Ruta, Costo) :-
    arista(Actual, Siguiente, C1),
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
%     |-- clause 1: arista(edmonton, calgary, _)       FAIL
%     |-- clause 2: arista(edmonton, Z, _)  Z = saskatoon
%           ruta_ingenua(saskatoon, calgary)
%             |-- clause 1: arista(saskatoon, calgary, _)  SUCCESS (true)
%             |-- clause 2 (on backtracking): Z = calgary
%                   ruta_ingenua(calgary, calgary)
%                     |-- clause 1: FAIL
%                     |-- clause 2: Z = edmonton -> ruta_ingenua(edmonton, calgary)
%                                   ... the initial goal again: INFINITE LOOP
%===============================================================================
ruta_ingenua(Origen, Destino) :- arista(Origen, Destino, _).
ruta_ingenua(Origen, Destino) :-
    arista(Origen, Intermedio, _),
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
