KERNEL   := vmlinuz64
INITRD   := initrd.img
CMDLINE  := earlyprintk=serial console=ttyS0 console=tty0 quiet loglevel=3
HDD      := data.qcow2
UUID     := 587BD56B-80A1-4142-8AB3-8AE94E367D48
USERNAME := docker
PASSWORD := docker

DOCKER_APP := /Applications/Docker.app

all: $(KERNEL) $(INITRD)

upgrade:
	@$(RM) $(KERNEL) $(INITRD)
	@$(MAKE)

$(KERNEL) $(INITRD):
	@install -CSpv -m 0644 $(DOCKER_APP)/Contents/Resources/moby/$@ .

xhyve_uuid:
	@echo $(UUID)

xhyve_kernel:
	@echo $(CURDIR)/$(KERNEL)

xhyve_initrd:
	@echo $(CURDIR)/$(INITRD)

xhyve_cmdline:
	@echo $(CMDLINE)

xhyve_hdd:
	@echo $(CURDIR)/$(HDD)

username:
	@echo $(USERNAME)

password:
	@echo $(PASSWORD)

ssh_args:
	@echo "-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

clean:
	$(RM) $(KERNEL) $(INITRD)
	$(RM) .mac_address

.PHONY: all upgrade xhyve_uuid xhyve_kernel xhyve_cmdline xhyve_hdd \
	username password ssh_args clean
