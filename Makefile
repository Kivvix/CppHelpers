### Nom du projet  #####################################################
PROJET  = <Project_Name>

# Different directories
SRCDIR  = src
HEADDIR = inc
LIBDIR  = obj
BINDIR  = bin

### Information général ################################################
# Commande to open editor for `make open`
EDITOR      = gedit
# Data need to be into archive with `make zip`
ARCHIVE    ?= README
# Data need to exectute the program for valgrind insepction
INPUT_ARGS ?= 


# Number of runs for benchmark
Nrun ?= 100

### Information structure projet #######################################
LANG        = C++
DEBUG_MODE ?= N

ifeq ($(LANG),C++)
	SRCEXT  = cpp
	HEADEXT = hpp
	CC      = g++
else
	SRCEXT  = c
	HEADEXT = h
	CC      = gcc
endif

### Information de compilation  #################1#######################
CFLAGS = -I$(HEADDIR) -I /usr/lib64/boost -Wall -Wextra
GLLIBS = -lm

ifeq ($(DEBUG_MODE),Y)
	CFLAGS += -g -pg
else
	CFLAGS += -O2
endif

SRC = $(wildcard $(SRCDIR)/*.$(SRCEXT))
OBJ = $(SRC:$(SRCDIR)/%.$(SRCEXT)=$(LIBDIR)/%.o)
INC = $(wildcard $(HEADDIR)/*.hpp)

WIDTH_TERM = $(shell tput cols)
DATE = $(shell date +%Y-%m-%d--%H-%M)
echo = /bin/echo

### Règles de compilation ##############################################
all : $(PROJET)
	@$(echo) -e " Executable : $(BINDIR)/$(PROJET)"

# Build exec
$(PROJET) : $(OBJ)
ifeq ($(DEBUG_MODE),Y)
	@$(echo) -e "\033[1mCompilation en mode debug \033[0m"
else
	@$(echo) -e "\033[1mCompilation en mode release \033[0m"
endif
	@$(echo) -e "\033[36m$(PROJET) \033[0m"
	@$(CC) -o $(BINDIR)/$@ $^ $(CFLAGS) $(GLLIBS)
	@$(echo) -ne "\033[90mCompilation finie.\033[0m"

# Build main.o from main.c and all header files
$(LIBDIR)/main.o : $(SRCDIR)/main.$(SRCEXT) $(INC)
	@$(echo) -e "\e[35mmain.o\033[0m"
	@$(CC) -o $@ -c $< $(CFLAGS)

# Build object files from *.c
$(LIBDIR)/%.o : $(SRCDIR)/%.$(SRCEXT) $(HEADDIR)/%.$(HEADEXT)
	@$(echo) -e "\033[95m"$(notdir $@)"\033[0m"
	@$(CC) -o $@ -c $< $(CFLAGS)


### .PHONY #############################################################
PHONY = clean mrpropre nuke zip val open café benchmark new old help action
.PHONY: $(PHONY)

clean :
	@$(echo) -e "\033[41;97;1m ** Suppression des fichier objets et sauvegarde ** \033[0m"
	rm -f $(LIBDIR)/*.o *~ $(SRCDIR)/*~ $(HEADDIR)/*~

mrproper : clean
	@$(echo) -e "\033[31;1mSuppression de l'exécutable \033[0m"
	rm -f $(BINDIR)/$(PROJET)
	@$(echo) -e "\033[31;1mSuppression de l'archive \033[0m"
	rm -f $(PROJET).tar.gz

nuke : mrproper
	@$(echo) -e "\033[91;1mSuppression de l'étude benchmark \033[0m"
	rm -f b.csv b.pdf
	@$(echo) -e "  ,-*\n (_)\n"

zip : mrproper
	@$(echo) -e "\033[44;97;1m Création de l'archive : $(PROJET).tar.gz \033[39;49;0m"
	@tar -zcvf $(PROJET).tar.gz $(SRCDIR)/*.$(SRCEXT) $(HEADDIR)/*.$(HEADEXT) Makefile $(ARCHIVE)

val : clean
	$(MAKE) DEBUG_MODE=Y
	valgrind --leak-check=yes ./$(BINDIR)/$(PROJET) $(INPUT_ARGS)

open :
	$(EDITOR) $(SRC) $(INC) &

café :
	@$(echo) " (\n  )\nc[]"

# TODO : passer à gnuplot pour une meilleure portabilité
# http://gnuplot.sourceforge.net/demo_canvas/boxplot.html
#benchmark : $(PROJET)
benchmark :
	@$(echo) -e "\n\033[42;97;1m Lancement de $(Nrun) run(s) \033[0m"
	@number=1 ; while [[ $$number -le $(Nrun) ]] ; do \
		$(echo) -ne $$number "$$(for i in `seq $$(($(WIDTH_TERM) - $${#number} - 7))`; do $(echo) -n ' '; done)" ; \
		bash -c "/usr/bin/time -f '%e,%U,%S' ./$(BINDIR)/$(PROJET) $(INPUT_ARGS) 2>&1 | tail -n 1" >> b.csv && $(echo) -e "[ \033[32mOK\033[0m ]" || $(echo) -e "[\033[91mFAIL\033[0m]" ; \
		((number = number + 1)) ; \
	done
	@Rscript -e "b_data  <- read.table('b.csv',sep=',',header=FALSE); pdf('b.pdf'); boxplot( list(b_data[[1]], b_data[[2]], b_data[[3]]) , col=c('pink','blue','green') ,names=c('real','user','sys') , main='Temps $(PROJET)' ); text( 1, 0.2 , mean( b_data[[1]] ) );text( 2, 0.2 , mean( b_data[[2]] ) ) ; text( 3, 0.2 , mean( b_data[[3]] ) );"
	@evince b.pdf &

new : clean $(PROJET)
	@$(echo) -e " Nouvel executable : $(BINDIR)/$(PROJET)"

# test pour éviter d'écraser le code avec l'ouverture d'une archive (pour ceux qui font du versioning à la main)
# pour le moment le test a été fait avec des fichier .a, il suffit de dupliquer le code pour l'effectuer sur les SRCEXT et HEADEXT
LISA = $(wildcard *.a)
old : $(addsuffix .old, $(LISA))
	@echo $(LISA)

%.a.old :
	@echo "plop %a"
	mv $*.a $*.a.old

summer :
	@for i in `seq 219 -1 214`; do $(echo) -en "\033[48;5;$${i}m " ; done ; $(echo) -ne "\033[48;5;214m  \033[1mSupression des vieux  "; for i in `seq 214 1 219` ; do $(echo) -en "\033[48;5;$${i}m \033[0m" ; done ; $(echo) -e ""
	rm -- *.old

licence :
	@$(echo) -e "\033[1mLicence du fichier Makefile\033[0m\n"
	@wget -O wget -q -O - http://sam.zoy.org/lprab/COPYING | cat

# règle qui machine les trucs dans nos coeurs !
# permet de récupérer les éléments suivant de la commande make pour entrer des arguments à la mano sans faire de `make MAVAR=truc cible`
action:	
	@[ -z '$(filter-out $@,$(MAKECMDGOALS))' ] && $(echo) "empty" || $(echo) "plop"

git:
	git commit -a -m $(filter-out $@,$(MAKECMDGOALS))

%:
	@[ -z $(findstring $(word 1,$(MAKECMDGOALS)),$(PHONY)) ] && $(echo) -e "No target \033[1m$(word 1,$(MAKECMDGOALS))\033[0m found." || :

help :
	@Pro="$(PROJET)";\
	echo " ═══ Projet $$Pro ═$$(for i in `seq $$(($(WIDTH_TERM) - $${#Pro} - 15))`; do $(echo) -n '═'; done)\n option du Makefile :\n	- clean     : nettoie les fichiers objets\n	- mrpropre  : nettoie les fichiers objets l'exécutable\n	- nuke      : nettoie tout\n	- zip       : crée une archive .tar.gz du projet\n	- val       : execute valgrind avec les options de la variable INPUT_ARGS\n	- open      : ouvre tous les fichiers avec $(EDITOR) (variable EDITOR)\n	- café      : fait le café\n	- benchmark : lance une mini-étude de benchmark\n	- new       : recréer un exécutable (clean + $(PROJET))\n	- licence   : affiche la licence du Makefile /!\\ cela n'indique en rien la licence du projet $(PROJET)\n	- help      : c'est ce que tu viens de faire abruiti"

