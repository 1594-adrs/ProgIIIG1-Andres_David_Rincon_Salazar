% Input for SLDNF Draw: SLD tree of padre_de(P, bart) of Pto01 (Act03).
% Same clauses as ProgIIIG1-Act03-Pto01 (persona/2, familia/2, hombre/1,
% progenitor_de/2, padre_de/2); member/2 is written out with its two
% standard clauses so that the traversal of the lists is drawn.
:- use_module(library(sldnfdraw)).
:- sldnf.
:- begin_program.
persona(abraham,    masculino).
persona(mona,       femenino).
persona(homero,     masculino).
persona(herbert,    masculino).
persona(clancy,     masculino).
persona(jacqueline, femenino).
persona(marge,      femenino).
persona(patty,      femenino).
persona(selma,      femenino).
persona(bart,       masculino).
persona(lisa,       femenino).
persona(maggie,     femenino).
persona(ling,       femenino).
familia([abraham, mona],       [homero]).
familia([abraham],             [herbert]).
familia([homero, marge],       [bart, lisa, maggie]).
familia([clancy, jacqueline],  [patty, selma, marge]).
familia([selma],               [ling]).
member(X, [X|Resto0]).
member(X, [Cabeza|Resto]) :- member(X, Resto).
hombre(Nombre) :- persona(Nombre, masculino).
progenitor_de(Progenitor, Hijo) :-
    familia(Progenitores, Hijos),
    member(Hijo, Hijos),
    member(Progenitor, Progenitores).
padre_de(Padre, Hijo) :- progenitor_de(Padre, Hijo), hombre(Padre).
:- end_program.
:- begin_query.
padre_de(P, bart).
:- end_query.
