## hacks

AeroThemePlasma includes [libplasma patches](https://gitgud.io/wackyideas/aerothemeplasma/-/tree/master/misc/libplasma) that are required for better looking tooltips in the plasmoids. I don't want to apply this patch outside of the AeroThemePlasma session in case it silently breaks, since that could render you without a working desktop environment (see [#7](https://github.com/nyakase/aerothemeplasma-nix/issues/7) which would be broken in regular Plasma if it was global).

This folder contains derivations for the patched libplasma and a slim build of plasma-workspace that is used by the login session. They are "hacks" because they have to tamper with the outputs to avoid collisions.
