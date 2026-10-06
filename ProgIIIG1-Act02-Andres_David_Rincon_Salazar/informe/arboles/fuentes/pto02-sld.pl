% Input for SLDNF Draw: SLD tree of the Pto02 program.
% Same clauses as ProgIIIG1-Act02-Pto02 except:
% - \+ is written not/1 (SLDNF Draw only typesets not/1 inside bodies).
% - the query is recorrer/5, the core of camino(coruna, vigo, C, Km):
%   camino/4 only adds reverse/2 to the result.
:- use_module(library(sldnfdraw)).
:- sldnf.
:- begin_program.
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
conectadas(A, B, Km) :- carretera(A, B, Km).
conectadas(A, B, Km) :- carretera(B, A, Km).
recorrer(Destino, Destino, Visitadas, Visitadas, 0).
recorrer(Actual, Destino, Visitadas, Ruta, Km) :-
    conectadas(Actual, Siguiente, Km1),
    not(memberchk(Siguiente, Visitadas)),
    recorrer(Siguiente, Destino, [Siguiente|Visitadas], Ruta, Km2),
    Km is Km1 + Km2.
:- end_program.
:- begin_query.
recorrer(coruna, vigo, [coruna], R, Km).
:- end_query.
