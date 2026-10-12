% Input for SLDNF Draw: SLD tree of the safe path of Pto02 (Act03).
% Same clauses as ProgIIIG1-Act03-Pto02 except:
% - \+ is written not/1 (SLDNF Draw only typesets not/1 inside bodies).
% - member/2 is written out with its two standard clauses (the anonymous
%   variable gets a name) so that the traversal of the lists is drawn.
% - the query is recorrer/5, the core of camino(edmonton, calgary, N, C):
%   camino/4 only adds reverse/2 to the result.
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
recorrer(Destino, Destino, Visitados, Visitados, 0).
recorrer(Actual, Destino, Visitados, Ruta, Costo) :-
    conexion_directa(Actual, Siguiente, C1),
    not(memberchk(Siguiente, Visitados)),
    recorrer(Siguiente, Destino, [Siguiente|Visitados], Ruta, C2),
    Costo is C1 + C2.
:- end_program.
:- begin_query.
recorrer(edmonton, calgary, [edmonton], R, C).
:- end_query.
