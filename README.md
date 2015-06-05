Sherbrooke Reglement 1
======================

Juste une tentative de tracker automatiquement des documents de la ville de
Sherbrooke dans Git.

Je ne suis pas l'auteur de ces PDF; ils sont mis sur Internet par la ville de
Sherbrooke.

Pour visualiser les diffs:

http://bvanheu.github.io/sherbrooke-reglement1

### Command line

Obtenir la liste des changements sur les reglements

> git log texte/sherbrooke_reglement1.txt

Obtenir le diff entre deux versions:

> git diff --ignore-blank-lines -a -b -w --word-diff REV1..REV2 texte/sherbrooke_reglement1.txt

### License

Domaine publique *sauf* ce qui se trouve dans `pdf/`, qui appartient a la ville
de Sherbrooke.

