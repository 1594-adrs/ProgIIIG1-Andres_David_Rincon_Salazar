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

hombre(herbert).
hombre(bart).

mujer(lisa).
mujer(maggie).
mujer(patty).
mujer(ling).

hombre(Nombre) :- padre_de(Nombre, _).
mujer(Nombre)  :- madre_de(Nombre, _).

progenitor_de(Padre, Hijo) :- padre_de(Padre, Hijo).
progenitor_de(Madre, Hijo) :- madre_de(Madre, Hijo).

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

abuelo_de(Abuelo, Nieto):-
    padre_de(Abuelo, Padre),
    progenitor_de(Padre, Nieto).

abuela_de(Abuela, Nieto):-
    madre_de(Abuela, Madre),
    progenitor_de(Madre, Nieto).

tio_de(Tio, Sobrino):-
    progenitor_de(Padre, Sobrino),
    hermano_de(Tio, Padre).

tia_de(Tia, Sobrino):-
    progenitor_de(Madre, Sobrino),
    hermana_de(Tia, Madre).

primo_de(Primo, Primo2):-
    progenitor_de(Padre, Primo),
    progenitor_de(Padre2, Primo2),
    hermano_de(Padre, Padre2).

prima_de(Prima, Prima2):-
    progenitor_de(Madre, Prima),
    progenitor_de(Madre2, Prima2),
    hermana_de(Madre, Madre2).