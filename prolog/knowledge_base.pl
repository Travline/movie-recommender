% Base de Hechos Auto-generada
director('the shawshank redemption', 'frank darabont').
genero('the shawshank redemption', 'drama').
director('the godfather', 'francis ford coppola').
genero('the godfather', 'crimen').
genero('the godfather', 'drama').
director('the dark knight', 'christopher nolan').
genero('the dark knight', 'accion').
genero('the dark knight', 'crimen').
genero('the dark knight', 'drama').
director('pulp fiction', 'quentin tarantino').
genero('pulp fiction', 'crimen').
genero('pulp fiction', 'drama').
director('inception', 'christopher nolan').
genero('inception', 'accion').
genero('inception', 'ciencia ficcion').
genero('inception', 'aventura').
director('the matrix', 'lana wachowski|lilly wachowski').
genero('the matrix', 'accion').
genero('the matrix', 'ciencia ficcion').
director('goodfellas', 'martin scorsese').
genero('goodfellas', 'biografia').
genero('goodfellas', 'crimen').
genero('goodfellas', 'drama').
director('seven', 'david fincher').
genero('seven', 'crimen').
genero('seven', 'drama').
genero('seven', 'misterio').
director('interstellar', 'christopher nolan').
genero('interstellar', 'aventura').
genero('interstellar', 'drama').
genero('interstellar', 'ciencia ficcion').
director('spirited away', 'hayao miyazaki').
genero('spirited away', 'animacion').
genero('spirited away', 'aventura').
genero('spirited away', 'fantasia').
director('parasite', 'bong joon ho').
genero('parasite', 'drama').
genero('parasite', 'thriller').
director('whiplash', 'damien chazelle').
genero('whiplash', 'drama').
genero('whiplash', 'musica').
director('gladiator', 'ridley scott').
genero('gladiator', 'accion').
genero('gladiator', 'aventura').
genero('gladiator', 'drama').
director('the departed', 'martin scorsese').
genero('the departed', 'crimen').
genero('the departed', 'drama').
genero('the departed', 'thriller').
director('the prestige', 'christopher nolan').
genero('the prestige', 'drama').
genero('the prestige', 'misterio').
genero('the prestige', 'ciencia ficcion').
director('django unchained', 'quentin tarantino').
genero('django unchained', 'drama').
genero('django unchained', 'western').
director('wall-e', 'andrew stanton').
genero('wall-e', 'animacion').
genero('wall-e', 'aventura').
genero('wall-e', 'familia').
director('the shining', 'stanley kubrick').
genero('the shining', 'terror').
genero('the shining', 'drama').
director('inglourious basterds', 'quentin tarantino').
genero('inglourious basterds', 'aventura').
genero('inglourious basterds', 'drama').
genero('inglourious basterds', 'guerra').
director('amelie', 'jean-pierre jeunet').
genero('amelie', 'comedia').
genero('amelie', 'romance').

% Reglas de Inferencia Lógica

% Verifica si una película comparte género con un elemento de la lista de gustos
comparte_genero(Peli, [G|Resto]) :- genero(Peli, G); comparte_genero(Peli, Resto).

% Verifica si una película comparte director con una de las favoritas
comparte_director(Peli, [F|Resto]) :- (director(F, Dir), director(Peli, Dir), Peli \= F); comparte_director(Peli, Resto).

% Regla principal que unifica Recomendaciones
recomendar(Favoritas, Generos, Recomendaciones) :-
    findall(Peli, (
        (comparte_genero(Peli, Generos); comparte_director(Peli, Favoritas)),
        \+ member(Peli, Favoritas) % No recomendar lo que ya es favorito
    ), ListaCruda),
    list_to_set(ListaCruda, Recomendaciones).
