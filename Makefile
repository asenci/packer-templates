ALL_TEMPLATE_DIRS := $(patsubst %/,%,$(dir $(wildcard **/packer.json)))
ALL_TEMPLATE_DIRS_TEST := $(foreach TARGET,$(ALL_TEMPLATE_DIRS),$(addsuffix !test,$(TARGET)))
ALL_TEMPLATE_DIRS_UPLOAD := $(foreach TARGET,$(ALL_TEMPLATE_DIRS),$(addsuffix !upload,$(TARGET)))

ALL_VERSIONS := $(wildcard vars/versions/*.json)
ALL_VERSIONS_TEST := $(foreach TARGET,$(ALL_VERSIONS),$(addsuffix !test,$(TARGET)))
ALL_OUTPUTS := $(foreach VERSION_VAR,$(ALL_VERSIONS),$(subst vars/versions/,build/,$(basename $(VERSION_VAR))))
ALL_BOXES := $(ALL_BOXES) $(foreach DIR,$(ALL_OUTPUTS),$(addsuffix /vagrant/parallels.box,$(DIR)))
ALL_BOXES := $(ALL_BOXES) $(foreach DIR,$(ALL_OUTPUTS),$(addsuffix /vagrant/vmware.box,$(DIR)))
ALL_BOXES_UPLOAD := $(foreach TARGET,$(ALL_BOXES),$(addsuffix !upload,$(TARGET)))

MAKE_ARGS := PACKER_ARGS="$(PACKER_ARGS)" PACKER_VARS="$(PACKER_VARS)"
MAKE_FILE = $(realpath $(lastword $(MAKEFILE_LIST)))
MAKE_ORIG_TEST = $(@:%!test=%)
MAKE_ORIG_UPLOAD = $(@:%!upload=%)

PACKER_BUILDER = $(notdir $(basename $(@)))-iso
PACKER_TEMPLATE := packer.json
PACKER_VAR_FILE = vars/versions/$(word 2,$(subst /, ,$(@))).json
override PACKER_VARS := $(addprefix -var ,$(PACKER_VARS))


.DEFAULT_GOAL := all
.PHONY: all
all: $(ALL_TEMPLATE_DIRS) $(ALL_BOXES)


.PHONY: test
test: $(ALL_TEMPLATE_DIRS_TEST) $(ALL_VERSIONS_TEST)


.PHONY: upload
upload: $(ALL_TEMPLATE_DIRS_UPLOAD) $(ALL_BOXES_UPLOAD)


ALL_JUNK := $(wildcard build) $(wildcard packer_cache) $(wildcard **/build) $(wildcard **/packer_cache)
.PHONY: clean $(ALL_JUNK)
clean: $(ALL_JUNK)
$(ALL_JUNK):
	$(RM) -r $(@)


.PHONY: $(ALL_TEMPLATE_DIRS)
$(ALL_TEMPLATE_DIRS):
	$(info === Building all under $(@) ===)
	cd $(@) && $(MAKE) -f $(MAKE_FILE) $(MAKE_ARGS)


.PHONY: $(ALL_TEMPLATE_DIRS_TEST)
$(ALL_TEMPLATE_DIRS_TEST):
	$(info === Validating all Packer templates under $(MAKE_ORIG_TEST) ===)
	cd $(MAKE_ORIG_TEST) && $(MAKE) -f $(MAKE_FILE) $(MAKE_ARGS) test


.PHONY: $(ALL_TEMPLATE_DIRS_UPLOAD)
$(ALL_TEMPLATE_DIRS_UPLOAD):
	$(info === Building all under $(MAKE_ORIG_UPLOAD) ===)
	cd $(MAKE_ORIG_UPLOAD) && $(MAKE) -f $(MAKE_FILE) $(MAKE_ARGS) upload


$(ALL_BOXES):
	$(info == Building $(@) ==)
	jq 'del(."post-processors"[][] | select(.type == "vagrant-cloud"))' $(PACKER_TEMPLATE) | packer build -only='$(PACKER_BUILDER)' -var-file=$(PACKER_VAR_FILE) $(PACKER_VARS) $(PACKER_ARGS) -


.PHONY: $(ALL_BOXES_UPLOAD)
$(ALL_BOXES_UPLOAD):
	$(info == Building $(MAKE_ORIG_UPLOAD) and will upload to Vagrant Cloud ==)
	packer build -only='$(PACKER_BUILDER)' -var-file=$(PACKER_VAR_FILE) $(PACKER_VARS) $(PACKER_ARGS) $(PACKER_TEMPLATE)


.PHONY: $(ALL_VERSIONS_TEST)
$(ALL_VERSIONS_TEST):
	$(info == Validating Packer template with $(MAKE_ORIG_TEST) ==)
	packer validate -var-file=$(MAKE_ORIG_TEST) $(PACKER_VARS) $(PACKER_ARGS) $(PACKER_TEMPLATE)


.SECONDEXPANSION:
$(ALL_BOXES): $$(PACKER_TEMPLATE) $$(PACKER_VAR_FILE)
