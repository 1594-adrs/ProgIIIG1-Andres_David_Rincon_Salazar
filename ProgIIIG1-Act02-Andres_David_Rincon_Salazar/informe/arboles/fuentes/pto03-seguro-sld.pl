% Input for SLDNF Draw: SLD tree of the safe path of Pto03.
% Same clauses as ProgIIIG1-Act02-Pto03 except:
% - \+ is written not/1 (SLDNF Draw only typesets not/1 inside bodies).
% - the query is recorrer/5, the core of camino(edmonton, calgary, N, C):
%   camino/4 only adds reverse/2 to the result.
:- use_module(library(sldnfdraw)).
:- sldnf.
:- begin_program.
arista(vancouver, edmonton,  16).
arista(vancouver, calgary,   13).
arista(edmonton,  saskatoon, 12).
arista(calgary,   edmonton,   4).
arista(calgary,   regina,    14).
arista(saskatoon, calgary,    9).
arista(saskatoon, winnipeg,  20).
arista(regina,    saskatoon,  7).
arista(regina,    winnipeg,   4).
recorrer(Destino, Destino, Visitados, Visitados, 0).
recorrer(Actual, Destino, Visitados, Ruta, Costo) :-
    arista(Actual, Siguiente, C1),
    not(memberchk(Siguiente, Visitados)),
    recorrer(Siguiente, Destino, [Siguiente|Visitados], Ruta, C2),
    Costo is C1 + C2.
:- end_program.
:- begin_query.
recorrer(edmonton, calgary, [edmonton], R, C).
:- end_query.
