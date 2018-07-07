ELIOM_SRC = $(shell find src -name "*.eliom")
ELIOMI_SRC = $(shell find src -name "*.eliomi")
STATIC = $(shell find static/)

.PHONY: all clean build install run

FONTS = /var/data/static/fonts /var/data/static/fonts/Montserrat /var/data/static/fonts/untitled-font-5 /var/data/static/fonts/Fira_Sans /var/data/static/fonts/Fira_Sans_Condensed  /var/data/static/fonts/Roboto_Condensed
INSTALL_DIRECTORIES = /var/lib/weles /var/log/weles /var/data /var/run /var/data/static /var/data/static/css /var/data/static/js $(FONTS) /var/data/static/images /var/data/static/images/icons /var/data/static/images/simple_icons /var/lib/eliom /etc/weles
INSTALL_CONFIG = $(addprefix /etc/weles, /weles.conf)
INSTALL_STATIC = $(addprefix /var/data/, $(STATIC))
INSTALL_SCSS = /var/data/static/css/main.css

all: compile

install:$(INSTALL_DIRECTORIES) \
	$(INSTALL_CONFIG) \
	$(INSTALL_STATIC) \
	$(INSTALL_SCSS) \
	/var/data/static/weles.js \
	/var/lib/weles/weles.cma

compile: /opt/build/weles.js /opt/build/weles.cma /opt/build/css/main.css

clean:
	-rm -f /opt/build/*.cm[ioax] /opt/build/*.cmxa /opt/build/*.cmxs /opt/build/*.o /opt/build/*.a /opt/build/*.annot
	-rm -f /opt/build/*.type_mli
	-rm -f /opt/build/weles.js
	-rm -rf /opt/build/_client/* /opt/build/_server/* /opt/build/css
	-rm -f /opt/build/*.eliom /opt/build/*.eliomi /opt/build/.depend /opt/build/.depend.server /opt/build/.depend.client /opt/build/Makefile

deps_clean:
	-rm -f /opt/build/.depend
	-rm -f /opt/build/.depend.server
	-rm -f /opt/build/.depend.client
	-rm -f /opt/build/_server/final.target /opt/build/_server/depsort
	-rm -f /opt/build/_client/final.target /opt/build/_client/depsort
	-rm -f /opt/build/weles.cm[ax] /opt/build/weles.cmxa /opt/build/weles.js

run: install
	rm -f /var/data/ocsipersist/socket
	ocsigenserver -v -c /etc/weles/weles.conf

infer: /opt/build/${MODULE}.eliom
	make -C /opt/build infer MODULE=${MODULE}

deps :
	make -C /opt/build depend

/opt/build/weles.js /opt/build/weles.cma: /opt/build/Makefile $(addprefix /opt/build/,$(notdir ${ELIOM_SRC})) $(addprefix /opt/build/,$(notdir ${ELIOMI_SRC}))
	make -j -C /opt/build

/var/lib/weles/weles.cma: /opt/build/weles.cma
	install -D $^ $@

/etc/weles/%.conf: conf/%.conf
	install -m 644 $^ $@

$(INSTALL_DIRECTORIES):
	install -o dev  -d $@

/var/data/static/weles.js: /opt/build/weles.js
	install -T -m 644 $^ $@

/var/data/static/%: static/%
	install -D -m 644 $^ $@

/var/data/static/css/%.css : /opt/weles/static/css/%.css
	install -D -m 644 $^ $@

/opt/build/Makefile: src/Makefile
	cp $^ $@

define cp_template =
/opt/build/$(notdir $(1)) : $(1)
	-cp $(1) /opt/build/$(notdir $(1))
endef

$(foreach file,$(ELIOM_SRC),$(eval $(call cp_template,$(file))))
$(foreach file,$(ELIOMI_SRC),$(eval $(call cp_template,$(file))))
