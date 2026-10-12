% Input for SLDNF Draw: SLD tree of ruta_ingenua/2 of Pto02 (Act03).
% Same clauses as ProgIIIG1-Act03-Pto02 except that the anonymous
% variable of conexion_directa/3 is named C, and member/2 is written out
% with its two standard clauses so that the lists are traversed in the tree.
% The tree is infinite: generar.sh builds it to a fixed depth.
:- use_module(library(sldnfdraw)).
:- sldnf.
:- begin_program.
member(X, [X|Resto0]).
member(X, [Cabeza|Resto]) :- member(X, Resto).
nodo(vancouver, [enlace(edmonton, 16), enlace(calgary, 13)]).
nodo(edmonton,  [enlace(saskatoon, 12)]).
nodo(calgary,   [enlace(edmonton, 4), enlace(regina, 14)]).
nodo(saskatoon, [enlace(calgary, 9), enlace(winnipeg, 20)]).
nodo(regina,    [enlace(saskatoon, 7), enlace(winnipeg, 4)]).
nodo(winnipeg,  []).
conexion_directa(A, B, Costo) :-
    nodo(A, Enlaces),
    member(enlace(B, Costo), Enlaces).
ruta_ingenua(Origen, Destino) :- conexion_directa(Origen, Destino, C).
ruta_ingenua(Origen, Destino) :-
    conexion_directa(Origen, Intermedio, C),
    ruta_ingenua(Intermedio, Destino).
:- end_program.
:- begin_query.
ruta_ingenua(edmonton, calgary).
:- end_query.
