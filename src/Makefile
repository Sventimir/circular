APP_NAME := weles

## Packages required to build the server part of the application

SERVER_PACKAGES := core ppx_let lwt.ppx ppx_sexp_conv ppx_fields_conv ppx_deriving.std camomile calendar yojson

## Packages to be linked in the client part

CLIENT_PACKAGES := ppx_let lwt.ppx ppx_sexp_conv js_of_ocaml js_of_ocaml.ppx ppx_deriving.std calendar yojson

## Source files for the server part

SERVER_INCLUDE := ${wildcard *.eliomi}

SERVER_FILES := ${wildcard *.eliom}

## Source files for the client part

CLIENT_INCLUDE := ${SERVER_INCLUDE}
CLIENT_FILES := ${SERVER_FILES}

## Required binaries

ELIOMC      := eliomc
ELIOMOPT    := eliomopt
ELIOMDEP    := eliomdep
JS_OF_ELIOM := js_of_eliom -g -jsopt +nat.js #-jsopt --pretty

## Where to put intermediate object files.
## - ELIOM_{SERVER,CLIENT}_DIR must be distinct
## - ELIOM_CLIENT_DIR mustn't be the local dir.
## - ELIOM_SERVER_DIR could be ".", but you need to
##   remove it from the "clean" rules...

export ELIOM_SERVER_DIR := _server
export ELIOM_CLIENT_DIR := _client
export ELIOM_TYPE_DIR   := .

#####################################

all: byte
byte:: ${APP_NAME}.cma ${APP_NAME}.js
opt:: ${APP_NAME}.cmxs ${APP_NAME}.js

#### Server side compilation #######


SERVER_INC  := -ppx ${addprefix -package ,${SERVER_PACKAGES}} -I ${ELIOM_SERVER_DIR} -I ${ELIOM_TYPE_DIR}

SERVER_IFAC := $(patsubst %.eliomi,${ELIOM_SERVER_DIR}/%.cmi, ${SERVER_INCLUDE})


include _server/final.target

infer: ${MODULE}.eliom
	${ELIOMC} -i ${SERVER_INC} $<

${ELIOM_TYPE_DIR}/%.type_mli: %.eliom
	${ELIOMC} -infer ${SERVER_INC} $<

${ELIOM_SERVER_DIR}/%.cmi: %.eliomi
	${ELIOMC} -c ${SERVER_INC} $<

${ELIOM_SERVER_DIR}/%.cmo: %.eliom ${ELIOM_TYPE_DIR}/%.type_mli
	${ELIOMC} -c ${SERVER_INC} $<

${ELIOM_SERVER_DIR}/%.cmx: %.eliom
	${ELIOMOPT} -c ${SERVER_INC} $<

%.cmxs: %.cmxa
	$(ELIOMOPT) -shared -linkall -o $@ $<

##### Client side compilation ####

CLIENT_LIBS := ${addprefix -package ,${CLIENT_PACKAGES}}
CLIENT_INC  := -ppx ${addprefix -package ,${CLIENT_PACKAGES}} -I ${ELIOM_CLIENT_DIR} -I ${ELIOM_TYPE_DIR}

CLIENT_IFAC := $(patsubst %.eliomi,${ELIOM_CLIENT_DIR}/%.cmi, ${CLIENT_INCLUDE})

include _client/final.target

${ELIOM_CLIENT_DIR}/%.cmi: %.eliomi
	${JS_OF_ELIOM} -c ${CLIENT_INC} $<

${ELIOM_CLIENT_DIR}/%.cmo: %.eliom ${ELIOM_TYPE_DIR}/%.type_mli
	${JS_OF_ELIOM} -c ${CLIENT_INC} $<

distclean: clean.local
	-rm -f *~ \#* .\#*

## Dependencies
## NOTE: neither .depend nor final.targets depend on any source files, so they
## won't be regenerated on every compilation. This is because eliomdep is not
## very fast for large numbers of modules. Thus you have to make clean manually
## if dependencies between modules go out of date.

depend: .depend
.depend: .depend.server .depend.client
	cat .depend.server .depend.client > .depend

.depend.server:
	$(ELIOMDEP) -server ${SERVER_INC} ${SERVER_FILES} ${SERVER_INCLUDE} > .depend.server

.depend.client:
	$(ELIOMDEP) -client ${CLIENT_INC} ${CLIENT_FILES} ${CLIENT_INCLUDE} > .depend.client

_server/final.target: _server/depsort
	@echo -e "\$${APP_NAME}.cma: \$${SERVER_IFAC} $(patsubst %.eliom,${ELIOM_SERVER_DIR}/%.cmo, $(shell cat $^))" > $@
	@echo -e "\t\$${ELIOMC} -a -o \$$@ $(patsubst %.eliom,${ELIOM_SERVER_DIR}/%.cmo, $(shell cat $^))" >> $@
	@echo -e "\n\$${APP_NAME}.cmxa: $(patsubst %.eliom,${ELIOM_SERVER_DIR}/%.cmx, $(shell cat $^))" >> $@
	@echo -e "\t\$${ELIOMOPT} -a -o \$$@ \$$^" >> $@

_client/final.target: _client/depsort
	@echo -e "\$${APP_NAME}.js: \$${CLIENT_IFAC} \$$(patsubst %.eliom,\$${ELIOM_CLIENT_DIR}/%.cmo, $(shell cat $^))" > $@
	@echo -e "\t\$${JS_OF_ELIOM} -thread -o \$$@ \$${CLIENT_LIBS} \$$(patsubst %.eliom,\$${ELIOM_CLIENT_DIR}/%.cmo, $(shell cat $^))" >> $@

_server/depsort:
	$(ELIOMDEP) -server -sort ${SERVER_INC} ${SERVER_FILES} > $@

_client/depsort:
	$(ELIOMDEP) -client -sort ${CLIENT_INC} ${CLIENT_FILES} > $@

## Warning: Dependencies towards *.eliom are not handled by eliomdep yet.

include .depend
