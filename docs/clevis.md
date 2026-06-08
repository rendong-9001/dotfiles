## Clevis(version=20)
### Fix Bugs
```sh
`/usr/lib/dracut/modules.d/60clevis/clevis-hook.sh` # comment out `set -eu`
`/usr/libexec/clevis-luks-unlocker` # replace `#!/bin/sh` with `#!/bin/bash`
```
