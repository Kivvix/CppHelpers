### Nom du projet  #####################################################
PROJET      = <Project_Name>

### Information général ################################################
# Commande to open editor for `make open`
EDITOR      = gedit
# Data need to be into archive with `make zip`
ARCHIVE    ?= 
# Data need to exectute the program for valgrind insepction
INPUT_ARGS ?= 


# Number of runs for benchmark
Nrun ?= 100

### Information structure projet #######################################
LANG        = C++
DEBUG_MODE ?= N

# Different directories
SRCDIR  = src
HEADDIR = inc
LIBDIR  = obj
BINDIR  = bin

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

DATE = $(shell date +%Y-%m-%d--%H-%M)

### Règles de compilation ##############################################
all : $(PROJET)
	@echo -e " Executable : $(BINDIR)/$(PROJET)"

# Build exec
$(PROJET) : $(OBJ)
ifeq ($(DEBUG_MODE),Y)
	@echo -e "\033[1mCompilation en mode debug \033[0m"
else
	@echo -e "\033[1mCompilation en mode release \033[0m"
endif
	@echo -e "\033[36m$(PROJET) \033[0m"
	@$(CC) -o $(BINDIR)/$@ $^ $(CFLAGS) $(GLLIBS)
	@echo -ne "\033[90mCompilation finie.\033[0m"

# Build main.o from main.c and all header files
$(LIBDIR)/main.o : $(SRCDIR)/main.$(SRCEXT) $(INC)
	@echo -e "\e[35mmain.o\033[0m"
	@$(CC) -o $@ -c $< $(CFLAGS)

# Build object files from *.c
$(LIBDIR)/%.o : $(SRCDIR)/%.$(SRCEXT) $(HEADDIR)/%.$(HEADEXT)
	@echo -e "\033[95m"$(notdir $@)"\033[0m"
	@$(CC) -o $@ -c $< $(CFLAGS)


### .PHONY #############################################################
.PHONY: clean mrpropre nuke zip val open café benchmark new old help

clean :
	@echo -e "\033[41;97;1m ** Suppression des fichier objets et sauvegarde ** \033[0m"
	rm -f $(LIBDIR)/*.o *~ $(SRCDIR)/*~ $(HEADDIR)/*~

mrproper : clean
	@echo -e "\033[31;1mSuppression de l'exécutable \033[0m"
	rm -f $(BINDIR)/$(PROJET)
	@echo -e "\033[31;1mSuppression de l'archive \033[0m"
	rm -f $(PROJET).tar.gz

nuke : mrproper
	@echo -e "\033[91;1mSuppression de l'étude benchmark \033[0m"
	rm -f b.csv b.pdf
	@echo -e "  ,-*\n (_)\n"

zip : mrproper
	@echo -e "\033[44;97;1m Création de l'archive : $(PROJET).tar.gz \033[39;49;0m"
	@tar -zcvf $(PROJET).tar.gz $(SRCDIR)/*.$(SRCEXT) $(HEADDIR)/*.$(HEADEXT) Makefile $(ARCHIVE)

val : clean
	$(MAKE) DEBUG_MODE=Y
	valgrind --leak-check=yes ./$(BINDIR)/$(PROJET) $(INPUT_ARGS)

open :
	$(EDITOR) $(SRC) $(INC) &

café :
	@echo -e " (\n  )\nc[]"

benchmark : $(PROJET)
	@echo -e "\n\033[42;97;1m Lancement de $(Nrun) run(s) \033[0m"
	@number=1 ; while [[ $$number -le $(Nrun) ]] ; do \
		echo -ne "\t" $$number  ; \
		bash -c "/usr/bin/time -f '%e,%U,%S' ./$(BINDIR)/$(PROJET) $(INPUT_ARGS) 2>&1 | tail -n 1" >> b.csv ; \
		echo -e "\t\t\t\t[ \033[32mOK\033[0m ] "; \
		((number = number + 1)) ; \
	done
	@Rscript -e "b_data  <- read.table('b.csv',sep=',',header=FALSE); pdf('b.pdf'); boxplot( list(b_data[[1]], b_data[[2]], b_data[[3]]) , col=c('pink','blue','green') ,names=c('real','user','sys') , main='Temps $(PROJET)' ); text( 1, 0.2 , mean( b_data[[1]] ) );text( 2, 0.2 , mean( b_data[[2]] ) ) ; text( 3, 0.2 , mean( b_data[[3]] ) );"
	@evince b.pdf &

new : clean $(PROJET)
	@echo -e " Nouvel executable : $(BINDIR)/$(PROJET)"

# test pour éviter d'écraser le code avec l'ouverture d'une archive (pour ceux qui font du versioning à la main)
# pour le moment le test a été fait avec des fichier .a, il suffit de dupliquer le code pour l'effectuer sur les SRCEXT et HEADEXT
LISTA = $(wildcard *.a)
old : $(addsuffix .old, $(LISTA))
	@echo $(LISTA)

%.a.old :
	@echo "plop %a"
	mv $*.a $*.a.old

summer :
	@for i in {219..214} ; do echo -en "\033[48;5;$${i}m " ; done ; echo -ne "\033[48;5;214m  \033[1mSupression des vieux  "; for i in {214..219} ; do echo -en "\033[48;5;$${i}m \033[0m" ; done ; echo -e ""
	rm *.old

licence :
	@echo -e "\033[1mLicence du fichier Makefile\033[0m\n \033[41;30;1m/!\ \033[0m Cela n'indique en rien la licence du projet $(PROJET)\n"
	@wget -O wget -q -O - http://sam.zoy.org/lprab/COPYING | cat

help :
	@ echo -e " ═══ Projet $(PROJET) ══════════════════\n option du Makefile :\n	- clean     : nettoie les fichiers objets\n	- mrpropre  : nettoie les fichiers objets l'exécutable\n	- nuke      : nettoie tout\n	- zip       : crée une archive .tar.gz du projet\n	- val       : execute valgrind avec les options de la variable INPUT_ARGS\n	- open      : ouvre tous les fichiers avec $(EDITOR) (variable EDITOR)\n	- café      : fait le café\n	- benchmark : lance une mini-étude de benchmark\n	- new       : recréer un exécutable (clean + $(PROJET))\n	- licence   : affiche la licence du Makefile /!\\ cela n'indique en rien la licence du projet $(PROJET)\n	- help      : c'est ce que tu viens de faire connard"

