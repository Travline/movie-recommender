import csv

def generar_prolog():
    csv_file = "pelis.csv"
    pl_file = "prolog/knowledge_base.pl"
    
    facts = []
    
    with open(csv_file, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['nombre'].strip().lower().replace("'", "\\'")
            director = row['director'].strip().lower().replace("'", "\\'")
            generos = [g.strip().lower().replace("'", "\\'") for g in row['generos'].split('|')]
            
            # Hechos directos de director
            facts.append(f"director('{name}', '{director}').")
            # Hechos por cada género
            for g in generos:
                facts.append(f"genero('{name}', '{g}').")
                
    rules = """
% Verifica si una película comparte género con un elemento de la lista de gustos
comparte_genero(Peli, [G|Resto]) :- genero(Peli, G); comparte_genero(Peli, Resto).

% Verifica si una película comparte director con una de las favoritas
comparte_director(Peli, [F|Resto]) :- (director(F, Dir), director(Peli, Dir), Peli \\= F); comparte_director(Peli, Resto).

% Regla principal que unifica Recomendaciones
recomendar(Favoritas, Generos, Recomendaciones) :-
    findall(Peli, (
        (comparte_genero(Peli, Generos); comparte_director(Peli, Favoritas)),
        \\+ member(Peli, Favoritas) % No recomendar lo que ya es favorito
    ), ListaCruda),
    list_to_set(ListaCruda, Recomendaciones).
"""
    
    with open(pl_file, 'w', encoding='utf-8') as out:
        out.write("% Base de Hechos Auto-generada\n")
        out.write("\n".join(facts))
        out.write("\n\n% Reglas de Inferencia Lógica\n")
        out.write(rules)
    print("¡Base de conocimiento 'knowledge_base.pl' generada con éxito!")

if __name__ == '__main__':
    generar_prolog()