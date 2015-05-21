include ${FSLCONFDIR}/default.mk

PROJNAME = asl_deblur

SCRIPTS = asl_deblur

all:
	@echo "Installing special scripts and binaries"
	@echo " Installing run_asl_deblur_core"
	@${CP} asl_deblur_core/distrib/run_asl_deblur_core.sh ${dest_BINDIR}/run_asl_deblur_core
	@if [ -d asl_deblur_core/distrib/asl_deblur_core.app ]; then \
		echo " Installing asl_deblur_core.app" ; \
	 	${CP} -rf asl_deblur_core/distrib/asl_deblur_core.app ${dest_BINDIR}/ ;\
	fi;
	@if [ -f asl_deblur_core/distrib/asl_deblur_core ]; then \
		echo " Installing asl_deblur_core" ; \
	 	${CP} -rf asl_deblur_core/distrib/asl_deblur_core ${dest_BINDIR}/ ;\
	fi;