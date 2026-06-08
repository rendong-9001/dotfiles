## Knot-resolver
### 1.slice_randomize_psl
```bash
sudo xbps-install lua51-devel libpsl-devel luarocks-lua51
sudo luarocks install --tree=/usr/local psl
```
### 2.Kresd
`edit kresd.conf`
```lua
policy.add(policy.slice(
	policy.slice_randomize_psl()
	policy.TLS_FORWARD({
		{'223.5.5.5', hostname='dns.alidnus.com'},
		{'223.6.6.6', hostname='dns.alidns.com'},
	}),
	policy.TLS_FORWARD({
		{'1.12.12.12', hostname='dot.pub'},
		{'120.53.53.53', hostname='dot.pub'},
	})
))
```
### 3.Remove
```bash
sudo luarocks remove --tree=/usr/local --force psl
```
