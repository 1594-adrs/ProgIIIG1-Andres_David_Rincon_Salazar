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
Formalization in predicate logic of the legal statement: "It is a crime
for an American to sell weapons to a hostile nation." Facts state that
West is American, that South Korea is a hostile nation and that West sold
weapons to South Korea. A rule defines criminality as the conjunction of
those conditions, proving that Colonel West is a criminal. Validation
queries are included at the end of the file.

Predicates description:
- es_estadounidense(Persona): (fact) Persona is an American citizen.
- es_pais_enemigo(Pais): (fact) Pais is a hostile nation.
- venta_de_armas(Persona, Pais): (fact) Persona sold weapons to Pais.
- es_criminal(Persona): (rule) criminal if American, seller of weapons,
  and the buyer country is hostile.

Warnings (Salvedades):
- The missiles of the problem statement are represented by the single
  fact venta_de_armas(west, corea_del_sur); the conclusion remains valid.
- Closed-world scenario: only west and corea_del_sur are modeled.
===============================================================================
*/

% La ley dice que es un crimen para un Estadounidense vender armas a naciones
% hostiles. Corea del Sur, enemigo de Estados Unidos, tiene algunos misiles, y todos
% sus misiles les fueron vendidos por el Coronel West, quien es Estadounidense.
% Pruebe que el Col. West es un criminal.

%===============================================================================
% FACTS: premises from the problem statement
%===============================================================================
es_estadounidense(west).

es_pais_enemigo(corea_del_sur).

venta_de_armas(west, corea_del_sur).

%===============================================================================
% RULE: a person is a criminal if American, sells weapons, and the
% buyer country is hostile
%===============================================================================
es_criminal(Persona) :- 
    es_estadounidense(Persona), 
    venta_de_armas(Persona, Pais), 
    es_pais_enemigo(Pais).

/*
===============================================================================
Validation queries
===============================================================================
?- es_estadounidense(west).
true.
?- es_pais_enemigo(corea_del_sur).
true.
?- venta_de_armas(west, corea_del_sur).
true.
?- es_criminal(west).
true.
?- es_criminal(X).
X = west.
?- es_criminal(homero).
false.
===============================================================================
*/