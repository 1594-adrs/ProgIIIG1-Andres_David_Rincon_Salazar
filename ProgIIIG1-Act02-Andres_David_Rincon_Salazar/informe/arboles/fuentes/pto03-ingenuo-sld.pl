% Input for SLDNF Draw: SLD tree of ruta_ingenua/2 of Pto03.
% Same clauses as ProgIIIG1-Act02-Pto03 except that the anonymous
% variable of arista/3 is named C, because the tool cannot typeset _.
% The tree is infinite: generar.sh builds it to a fixed depth.
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
ruta_ingenua(Origen, Destino) :- arista(Origen, Destino, C).
ruta_ingenua(Origen, Destino) :-
    arista(Origen, Intermedio, C),
    ruta_ingenua(Intermedio, Destino).
:- end_program.
:- begin_query.
ruta_ingenua(edmonton, calgary).
:- end_query.
