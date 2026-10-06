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
Shortest routes over the undirected road map of Spain (distances in km).
Roads are stored once as facts and made symmetric by a rule. Paths are
enumerated by backtracking with a list of visited cities (to avoid
infinite loops in the undirected graph); the shortest route is the
minimum over all of them. Validation queries are included at the end.

Predicates description:
- carretera(A, B, Km): (fact) road between A and B (stored once).
- conectadas(A, B, Km): (rule) symmetric closure of carretera/3.
- camino(Origen, Destino, Ciudades, Km): (rule) simple path, with its
  list of cities and total distance.
- ruta_corta(Origen, Destino, Ciudades, Km): (rule) minimum-distance path.
- hay_ruta(Origen, Destino): (rule) some path exists.

Warnings (Salvedades):
- The label of the Jaen-Granada road is rotated in the slide and could be
  read as 99 or as 66; 99 was used because it matches the real road
  distance between both cities.
- Ciudad Real, mentioned in the GPS article of the slides, is not in the
  map and therefore is not modeled.
- camino/4 enumerates all simple paths: exponential in general, but fine
  for this 15-city map.
===============================================================================
*/

%===============================================================================
% FACTS: roads of the map, carretera(CiudadA, CiudadB, Km)
%===============================================================================
carretera(coruna,     vigo,       171).
carretera(coruna,     valladolid, 455).
carretera(vigo,       valladolid, 356).
carretera(oviedo,     bilbao,     304).
carretera(valladolid, bilbao,     280).
carretera(valladolid, madrid,     193).
carretera(bilbao,     madrid,     395).
carretera(bilbao,     zaragoza,   324).
carretera(zaragoza,   madrid,     325).
carretera(zaragoza,   barcelona,  296).
carretera(barcelona,  gerona,     100).
carretera(barcelona,  valencia,   349).
carretera(madrid,     badajoz,    403).
carretera(madrid,     jaen,       335).
carretera(madrid,     albacete,   251).
carretera(albacete,   valencia,   191).
carretera(albacete,   murcia,     150).
carretera(valencia,   murcia,     241).
carretera(jaen,       sevilla,    242).
carretera(jaen,       granada,     99).
carretera(sevilla,    granada,    256).
carretera(sevilla,    cadiz,      125).
carretera(granada,    murcia,     278).

%===============================================================================
% RULE: roads are two-way
%===============================================================================
conectadas(A, B, Km) :- carretera(A, B, Km).
conectadas(A, B, Km) :- carretera(B, A, Km).

%===============================================================================
% RULES: simple paths by backtracking
% The accumulator Visitadas keeps cities already used so a path never
% revisits a city (otherwise A-B-A-B... would never end).
%===============================================================================
camino(Origen, Destino, Ciudades, Km) :-
    recorrer(Origen, Destino, [Origen], CiudadesInv, Km),
    reverse(CiudadesInv, Ciudades).

recorrer(Destino, Destino, Visitadas, Visitadas, 0).
recorrer(Actual, Destino, Visitadas, Ruta, Km) :-
    conectadas(Actual, Siguiente, Km1),
    \+ memberchk(Siguiente, Visitadas),
    recorrer(Siguiente, Destino, [Siguiente|Visitadas], Ruta, Km2),
    Km is Km1 + Km2.

%===============================================================================
% RULES: shortest route and reachability
%===============================================================================
ruta_corta(Origen, Destino, Ciudades, Km) :-
    aggregate_all(min(K, C), camino(Origen, Destino, C, K), min(Km, Ciudades)).

hay_ruta(Origen, Destino) :-
    camino(Origen, Destino, _, _), !.

/*
===============================================================================
Validation queries
===============================================================================
?- conectadas(madrid, valladolid, Km).
Km = 193.
?- conectadas(valladolid, madrid, Km).
Km = 193.
?- camino(coruna, vigo, C, Km).
C = [coruna, vigo],
Km = 171 ;
C = [coruna, valladolid, vigo],
Km = 811 ;
false.
?- ruta_corta(coruna, gerona, C, Km).
C = [coruna, valladolid, madrid, zaragoza, barcelona, gerona],
Km = 1369.
?- ruta_corta(cadiz, oviedo, C, Km).
C = [cadiz, sevilla, jaen, madrid, bilbao, oviedo],
Km = 1401.
?- ruta_corta(madrid, madrid, C, Km).
C = [madrid],
Km = 0.
?- hay_ruta(badajoz, gerona).
true.
?- hay_ruta(madrid, paris).
false.
===============================================================================
*/
