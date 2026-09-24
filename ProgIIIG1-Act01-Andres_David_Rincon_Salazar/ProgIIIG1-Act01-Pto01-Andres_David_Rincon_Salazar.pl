/*
===============================================================================
Publication Date: 2026-09-23
Publication Time: 19:05
Code Version: 1.1
Author: Ing(c) Andres David Rincon Salazar
Programming Language: Prolog
Language Version: ISO/IEC 13211-1 (SWI-Prolog 10.0.2)
Compiler: SWI-Prolog 10.0.2
Operating System: Windows 11 - 24H2
Presented to: Ramiro Andres Barrios Valencia
University: Universidad Tecnologica de Pereira
Program: Ingenieria de Sistemas y Computacion

Program Description:
Family tree modeled with first-order predicates. Direct relationships
(father and mother) are asserted as facts; multi-generation relationships
(grandparents, siblings, uncles/aunts and cousins) are obtained only by
rules, as required by the activity. Validation queries are included at
the end of the file.

Predicates description:
- padre_de(Padre, Hijo), madre_de(Madre, Hijo): (facts) direct relations.
- hombre/1, mujer/1: (facts + rules) gender of each individual.
- progenitor_de(Parent, Child): (rule) generic parent (father or mother).
- es_hijo(Hijo, Padre): (rule) true when Hijo is child of Padre.
- hermano_de/2, hermana_de/2: (rules) siblings sharing one progenitor.
- abuelo_de/2, abuela_de/2: (rules) grandparents (more than one generation).
- tio_de/2, tia_de/2: (rules) uncle/aunt: sibling of a progenitor.
- primo_de/2, prima_de/2: (rules) cousins; gender checked on 1st argument.

Warnings (Salvedades):
- SWI-Prolog warns that clauses of hombre/1 and mujer/1 are not together;
  the program logic is not affected.
- Some queries may repeat solutions (two parents / gender proofs).
- primo_de/2 and prima_de/2 only check the gender of the first argument.
===============================================================================
*/

%===============================================================================
% FACTS: direct one-generation relationships (father/mother)
%===============================================================================
padre_de(abraham, homero).
padre_de(abraham, herbert).
padre_de(homero, bart).
padre_de(homero, lisa).
padre_de(homero, maggie).
padre_de(clancy, patty).
padre_de(clancy, selma).
padre_de(clancy, marge).

madre_de(mona, homero).
madre_de(marge, bart).
madre_de(marge, lisa).
madre_de(marge, maggie).
madre_de(jacqueline, patty).
madre_de(jacqueline, selma).
madre_de(jacqueline, marge).
madre_de(selma, ling).

%===============================================================================
% FACTS: gender of individuals not inferred by being a parent
%===============================================================================
hombre(herbert).
hombre(bart).

mujer(lisa).
mujer(maggie).
mujer(patty).
mujer(ling).

%===============================================================================
% RULES: gender inference for every parent
%===============================================================================
hombre(Nombre) :- padre_de(Nombre, _).
mujer(Nombre)  :- madre_de(Nombre, _).

%===============================================================================
% AUXILIARY RULE: generic parent (father or mother)
%===============================================================================
progenitor_de(Padre, Hijo) :- padre_de(Padre, Hijo).
progenitor_de(Madre, Hijo) :- madre_de(Madre, Hijo).

%===============================================================================
% RULE: child of a parent (es_hijo(Hijo, Padre))
%===============================================================================
es_hijo(Hijo, Padre) :-
    progenitor_de(Padre, Hijo).

%===============================================================================
% RULES: siblings (share at least one parent and are distinct)
%===============================================================================
hermano_de(Hijo1, Hijo2):-
    progenitor_de(Padre, Hijo1),
    progenitor_de(Padre, Hijo2),
    Hijo1 \= Hijo2,
    hombre(Hijo1).

hermana_de(Hijo1, Hijo2):-
    progenitor_de(Padre, Hijo1),
    progenitor_de(Padre, Hijo2),
    Hijo1 \= Hijo2,
    mujer(Hijo1).

%===============================================================================
% RULES: multi-generation relationships (grandfather/grandmother)
%===============================================================================
abuelo_de(Abuelo, Nieto):-
    padre_de(Abuelo, Padre),
    progenitor_de(Padre, Nieto).

abuela_de(Abuela, Nieto):-
    madre_de(Abuela, Madre),
    progenitor_de(Madre, Nieto).

%===============================================================================
% RULES: uncles/aunts (sibling of a parent of the nephew/niece)
%===============================================================================
tio_de(Tio, Sobrino):-
    progenitor_de(Padre, Sobrino),
    hermano_de(Tio, Padre).

tia_de(Tia, Sobrino):-
    progenitor_de(Madre, Sobrino),
    hermana_de(Tia, Madre).

%===============================================================================
% RULES: cousins (children of siblings; gender checked on 1st argument)
%===============================================================================
primo_de(Primo, Primo2):-
    progenitor_de(Padre1, Primo),
    progenitor_de(Padre2, Primo2),
    Padre1 \= Padre2,
    ( hermano_de(Padre1, Padre2) ; hermana_de(Padre1, Padre2) ),
	hombre(Primo).

prima_de(Prima, Prima2):-
    progenitor_de(Padre1, Prima),
    progenitor_de(Padre2, Prima2),
    Padre1 \= Padre2,
    ( hermano_de(Padre1, Padre2) ; hermana_de(Padre1, Padre2) ),
	mujer(Prima).

/*
===============================================================================
Validation queries
===============================================================================
?- padre_de(homero, bart).
true.
?- madre_de(marge, lisa).
true.
?- es_hijo(bart, homero).
true.
?- es_hijo(X, homero).
X = bart ;
X = lisa ;
X = maggie.
?- abuelo_de(abraham, X).
X = bart ;
X = lisa ;
X = maggie.
?- abuela_de(mona, bart).
true.
?- hermano_de(bart, lisa).
true.
?- hermana_de(lisa, bart).
true.
?- tio_de(herbert, bart).
true.
?- tia_de(patty, bart).
true.
?- primo_de(bart, ling).
true.
?- prima_de(ling, bart).
true.
?- abuelo_de(bart, X).
false.
===============================================================================
*/