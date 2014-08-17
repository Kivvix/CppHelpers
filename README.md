CppHelpers
==========

> Outils d'aide au développement en C++

Makefile
--------

Le **C++** est un langage compilé, l'étape de compilation s'effectue généralement à l'aide d'un fichier `Makefile`. Celui-ci se limite souvent à quelques règles comme la compilation, le nettoyage des fichiers objets issus de la compilation, et parfois à l'archivage des sources. Par simplification, nombreux programmeurs récupèrent simplement un `Makefile` déjà existant, ici il s'agit d'en proposer un réutilisable, et proposant de nombreuses règles d'aide à la compilation et au développement.

Ce fichier `Makefile` permet une compilation de fichiers séparer dans différents dossiers :
	* Un dossier contenu dans la variable `SRCDIR` pour les fichiers sources ;
	* Un dossier contenu dans la vairbale `HEADDIR` pour les fichiers d'en-tête ;
Les fichiers `.o` généré au moment de la compilation sont placés dans le dossier contenu dans la variable `LIBDIR`, et l'exécutable dans le dossier contenu dans la variable `BINDIR`.


`mktp`
------

Le script `mktp` permet de générer les premiers fichiers sources et d'en-tête pour accélérer la première étape de développement, création de la hiérarchie de fichiers et des fichiers contenant le descriptif des principales classes et leurs **getter** et **setter**.

Pour cela le script est entièrement écrit en **bash** à cause de la puissance des fonctions de gestion des chaînes de caractères comme `sed`, `awk` ou les fonctions intégrées au **Shell**.
