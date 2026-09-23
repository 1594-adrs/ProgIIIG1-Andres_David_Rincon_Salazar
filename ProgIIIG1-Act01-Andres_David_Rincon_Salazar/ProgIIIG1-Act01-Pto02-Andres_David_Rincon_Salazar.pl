% La ley dice que es un crimen para un Estadounidense vender armas a naciones
% hostiles. Corea del Sur, enemigo de Estados Unidos, tiene algunos misiles, y todos
% sus misiles les fueron vendidos por el Coronel West, quien es Estadounidense.
% Pruebe que el Col. West es un criminal.

es_estadounidense(west).

es_pais_enemigo(corea_del_sur).

venta_de_armas(west, corea_del_sur).

es_criminal(Persona) :- 
    es_estadounidense(Persona), 
    venta_de_armas(Persona, Pais), 
    es_pais_enemigo(Pais).