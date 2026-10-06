% Input for SLDNF Draw: SLD tree of the Pto01 program.
% Same clauses as ProgIIIG1-Act02-Pto01 except:
% - \+ is written not/1 (SLDNF Draw only typesets not/1 inside bodies).
% - the anonymous variables of paso(Id, _, _) are named, because the
%   tool cannot typeset _.
% - the query is caminar/5, the core of paseo(norte, Pasos): paseo/2 only
%   adds zona/1, aggregate_all/3 (Total = 7) and reverse/2.
:- use_module(library(sldnfdraw)).
:- sldnf.
:- begin_program.
puente(b1, norte, kneiphof).
puente(b2, norte, kneiphof).
puente(b3, sur,   kneiphof).
puente(b4, sur,   kneiphof).
puente(b5, norte, este).
puente(b6, sur,   este).
puente(b7, kneiphof, este).
cruce(Id, Desde, Hasta) :- puente(Id, Desde, Hasta).
cruce(Id, Desde, Hasta) :- puente(Id, Hasta, Desde).
caminar(Fin, Fin, Total, Usados, Usados) :- length(Usados, Total).
caminar(Actual, Fin, Total, Usados, Resultado) :-
    cruce(Id, Actual, Siguiente),
    not(memberchk(paso(Id, X, Y), Usados)),
    caminar(Siguiente, Fin, Total, [paso(Id, Actual, Siguiente)|Usados], Resultado).
:- end_program.
:- begin_query.
caminar(norte, norte, 7, [], P).
:- end_query.
