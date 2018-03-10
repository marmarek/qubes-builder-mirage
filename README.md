qubes-builder plugin for MirageOS based templates
-------------------------------------------------


Recognized builder.conf variables:


- `MIRAGE_KERNEL_PATH` - full path to precompiled unikernel image

Recoginzed `Makefile.builder` variables (for actual unikernel code):

- `MIRAGE_KERNEL_NAME` - name of output file with the unikernel
- `OCAML_VERSION` - preferred ocaml version (defaults to `system`)

Building the unikernel is done with:

    mirage configure -t xen
    make depends
    make

If any additional preparation steps are needed, use `SOURCE_BUILD_DEP` setting
in `Makefile.builder`. For example:

    SOURCE_BUILD_DEP = my-build-dep

    my-build-dep:
        opam pin add ...


Using mirage templates (Qubes 4.0)
----------------------------------

1. Install template rpm package
2. Create new AppVM with those settings:

    - `virt_mode=pv`
    - `kernel=pvgrub`
    - `kernelopts=(hd0)/boot/grub/menu.lst` (or `(hd0,0)/boot/grub/menu.lst` if
      template was built with `TEMPLATE_ROOT_WITH_PARTITIONS=1`)
    - `memory=32` (or appropriate value for given unikernel)

    Example command to do that at once:
    
        qvm-create -l green -t mirage \
            --prop virt_mode=pv \
            --prop kernel=pvgrub \
            --prop "kernelopts=(hd0)/boot/grub/menu.lst" \
            --prop memory=32 \
            NAME_OF_VM

3. For some applications, you may also want to adjust network settings - set
   `netvm` and/or `provides_network`.
4. Disable `gui` feature (unless the unikernel actually use gui):

        qvm-features mirage gui ''

    (use template name in place of `mirage` in the command)


Since MirageOS don't have built-in update mechanism, there is really no need to
start the template itself. Use AppVMs based on it.
