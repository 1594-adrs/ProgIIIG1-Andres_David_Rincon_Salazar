/*
===============================================================================
Publication Date: 2026-10-10
Publication Time: 21:30
Code Version: 1.0
Author: Ing(c) Andres David Rincon Salazar
Programming Language: Prolog
Language Version: ISO/IEC 13211-1 (SWI-Prolog 10.0.2)
Compiler: SWI-Prolog 10.0.2
Operating System: Windows 11 - 24H2
Presented to: Ramiro Andres Barrios Valencia
University: Universidad Tecnologica de Pereira
Program: Ingenieria de Sistemas y Computacion
Based on: ProgIIIG1-Act01-Pto01 (Simpson family, facts only)

Program Description:
Simpson family tree rewritten with structures and lists. The one-fact-per-
relationship model of Activity 1 (padre_de/2, madre_de/2, hombre/1, mujer/1)
is replaced by two kinds of facts:
  - persona(Nombre, Sexo): structure with the sex of each individual.
  - familia(Progenitores, Hijos): structure with two lists, the parents and
    the children of one household.
Every relationship of Activity 1 is still answered with the same predicate
names and arguments, but now it is a rule that traverses those lists with
member/2 and findall/3. Validation queries are included at the end of the file.

Predicates description:
- persona(Nombre, Sexo): (fact) Sexo is masculino or femenino.
- familia(Progenitores, Hijos): (fact) lists of parents and of children.
- hombre/1, mujer/1: (rules) sex of an individual, read from persona/2.
- progenitor_de(Progenitor, Hijo): (rule) member of a Progenitores list that
  has Hijo in the Hijos list of the same familia.
- hijos_de(Progenitor, Hijos): (rule) list of all children of Progenitor.
- padre_de/2, madre_de/2: (rules) progenitor_de/2 filtered by sex.
- es_hijo(Hijo, Padre): (rule) true when Hijo is child of Padre.
- hermano_de/2, hermana_de/2: (rules) siblings sharing one progenitor.
- abuelo_de/2, abuela_de/2: (rules) grandparents (more than one generation).
- tio_de/2, tia_de/2: (rules) uncle/aunt: sibling of a progenitor.
- primo_de/2, prima_de/2: (rules) cousins; sex checked on 1st argument.

Warnings (Salvedades):
- Herbert and Ling have a single known parent, so they are listed in their
  own familia/2 with one progenitor. Putting Herbert in the same familia
  as Homero would make Mona his mother, which Activity 1 never stated.
- A person with no persona/2 fact has no sex: padre_de/2, madre_de/2, and
  every rule that checks hombre/1 or mujer/1 fail for him or her.
- Some queries may repeat solutions (siblings share two parents).
- primo_de/2 and prima_de/2 only check the sex of the first argument.
===============================================================================
*/

%===============================================================================
% FACTS: structure persona(Nombre, Sexo)
%===============================================================================
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

%===============================================================================
% FACTS: structure familia(Progenitores, Hijos), both arguments are lists
%===============================================================================
familia([abraham, mona],       [homero]).
familia([abraham],             [herbert]).
familia([homero, marge],       [bart, lisa, maggie]).
familia([clancy, jacqueline],  [patty, selma, marge]).
familia([selma],               [ling]).

%===============================================================================
% RULES: sex of an individual, read from the persona/2 structure
%===============================================================================
hombre(Nombre) :- persona(Nombre, masculino).
mujer(Nombre)  :- persona(Nombre, femenino).

%===============================================================================
% RULES: generic parent and list of children
%===============================================================================
progenitor_de(Progenitor, Hijo) :-
    familia(Progenitores, Hijos),
    member(Hijo, Hijos),
    member(Progenitor, Progenitores).

hijos_de(Progenitor, Hijos) :-
    findall(Hijo, progenitor_de(Progenitor, Hijo), Hijos).

%===============================================================================
% RULES: father and mother (progenitor filtered by sex)
%===============================================================================
padre_de(Padre, Hijo) :- progenitor_de(Padre, Hijo), hombre(Padre).
madre_de(Madre, Hijo) :- progenitor_de(Madre, Hijo), mujer(Madre).

%===============================================================================
% RULE: child of a parent (es_hijo(Hijo, Padre))
%===============================================================================
es_hijo(Hijo, Padre) :-
    progenitor_de(Padre, Hijo).

%===============================================================================
% RULES: siblings (children of a common progenitor, distinct)
%===============================================================================
hermano_de(Hijo1, Hijo2) :-
    progenitor_de(Padre, Hijo1),
    hijos_de(Padre, Hijos),
    member(Hijo2, Hijos),
    Hijo1 \== Hijo2,
    hombre(Hijo1).

hermana_de(Hijo1, Hijo2) :-
    progenitor_de(Padre, Hijo1),
    hijos_de(Padre, Hijos),
    member(Hijo2, Hijos),
    Hijo1 \== Hijo2,
    mujer(Hijo1).

%===============================================================================
% RULES: multi-generation relationships (grandfather/grandmother)
%===============================================================================
abuelo_de(Abuelo, Nieto) :-
    padre_de(Abuelo, Padre),
    hijos_de(Padre, Nietos),
    member(Nieto, Nietos).

abuela_de(Abuela, Nieto) :-
    madre_de(Abuela, Madre),
    hijos_de(Madre, Nietos),
    member(Nieto, Nietos).

%===============================================================================
% RULES: uncles/aunts (sibling of a parent of the nephew/niece)
%===============================================================================
tio_de(Tio, Sobrino) :-
    progenitor_de(Padre, Sobrino),
    hermano_de(Tio, Padre).

tia_de(Tia, Sobrino) :-
    progenitor_de(Madre, Sobrino),
    hermana_de(Tia, Madre).

%===============================================================================
% RULES: cousins (children of siblings; sex checked on 1st argument)
%===============================================================================
primo_de(Primo, Primo2) :-
    progenitor_de(Padre1, Primo),
    ( hermano_de(Padre2, Padre1) ; hermana_de(Padre2, Padre1) ),
    hijos_de(Padre2, Primos),
    member(Primo2, Primos),
    hombre(Primo).

prima_de(Prima, Prima2) :-
    progenitor_de(Padre1, Prima),
    ( hermano_de(Padre2, Padre1) ; hermana_de(Padre2, Padre1) ),
    hijos_de(Padre2, Primas),
    member(Prima2, Primas),
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
?- hijos_de(homero, Hijos).
Hijos = [bart, lisa, maggie].
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
