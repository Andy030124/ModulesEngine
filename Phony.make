# $1: dir for delete
define RMDIR_COMMAND
$(call REMOVE_COMMAND,Removing directory: [$1],rm -rf $1)
endef

define EXECUTE_APP
$(call OTHER_COMMAND,Executing [$1],$1)
endef

.PHONY: clean exe cleanall

exe: $(APP)
	$(call EXECUTE_APP,./$(APP))

clean:
	$(call RMDIR_COMMAND,$(BUILD_DIR))
	$(call RMDIR_COMMAND,$(OBJDIR))

cleanall: clean
	$(call RMDIR_COMMAND,bin)

info:
	$(info $(STATIC_LIBS))
	$(info $(LIB_DIRS))
	$(info $(FLAGS))
	$(info $(LDFLAGS))
