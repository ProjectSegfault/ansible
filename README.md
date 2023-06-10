# Project Segfault Ansible (Production)

These are the ansible configs used in production on Project Segfault servers.

We have 2 different playbooks, one for setting up the basic things every one of our servers needs, and one for managing docker and caddy for our geographic nodes (mostly Privacy Frontends)

The configs/compose files for the Privacy Frontends are included here as well.

All files under this repo are licensed under the GPLv3, unless specified otherwise.

## Running Playbook(s)
Firstly, you need to install dependencies, which can be done with the following:
```
ansible-galaxy install -r requirements.yml -p roles/galaxy/ --force
```
Then, you can run the all playbook as such
```
ansible-playbook all/playbook.yaml # Initialize
```
For Privacy Frontends playbook, you need access to the ansible vault password, which you'll have if you are a segfault sysadmin :)
```
ansible-playbook -i inventory.yml -e @secrets.enc --ask-vault-pass privfrontends/playbook.yaml
```
Additionally, you can make use of the following ansible tags:
- caddy-non-update \- update Caddy configs but don't update caddy itself
- docker \- run docker compose stuff
- cron \- setup cronjobs for hourly restarts

Tags can be used with the following syntax: `--tag tag1,tag2,tag3`
## Ansible Vaults
Many parts of our privacy frontends configurations are meant to be private, such as HMAC keys and database passwords.

Hence, these are stored as variables using ansible-vault.

There are two different ansible-vaults in use in our setup, encrypted `host_vars` files per-host, and a global `secrets.enc`.

### secrets.enc
`/secrets.enc` contains private variables that are same for all our servers.
Currently, it contains the following: (as of 9/6/23)
- rfc2136_key \- RFC2136 key for DNS01
- watchtower_mtrx_pass \- Watchtower Matrix password

### host_vars
host_vars are dynamic variables that can be different for each host.
We have two encrypted host_vars files in our setup, one for the services, and one for healthchecks on cronjobs.
#### healthchecks.yaml (as of 9/6/23)
- invidious_hc_uuid - UUID for invidious hourly restart
- teddit_hc_uuid - UUID for teddit hourly restart
#### privfrontends_secrets.yaml (as of 9/6/23)
- scribe_secret_key_base
- nitter_hmac_key
- librarian_auth_token
- librarian_hmac_key
- searxng_secret_key
- anonymousoverflow_signing_secret

## Playbooks
### all
The `all` playbook contains the basics needed for every server on our infrastructure.
As of 9/6/23, it does the following:
- Installs vim, curl, wget, sudo, netstat, nmap, pip, chrony (ntp), vnstat (bw monitoring)
- Enables systemd services for VNStat and Chrony
- Adds bash configuration
- Creates users for the sysadmins and adds their ssh keys to it
- Allows sudo without password
- Adds an extra authorized_key on Soleil Levant servers for sshpiper
- Adds custom sshd configuration
### privfrontends
Our Geographic Privacy Frontends nodes are managed with this playbook.
As of 9/6/23, it does the following:
- Uses the caddy-ansible role to setup a caddy instance with the rfc2136 plugin added
- Copies per-server extras files
- Sets up the privacy frontends from a pre-defined list (it does ignore if there isnt any config change however to make sure its not extremely slow)
- Restart certain services every hour since they aren't very stable

## Adding new services
Firstly, add the thing to `docker_services` array/var in `/privfrontends/playbook.yaml`. This list **MUST** be maintaind in alphabetical order for ease of maintanence.

Then, create the `/compose/SERVICE_NAME` directory and add the compose file (compose.yml.j2) to the same. You can use the `{{inventory_hostname}}` variables where required.

If the service needs a secret key, add it to the ansible-vault secrets.enc with `ansible-vault edit secrets.enc`. If you are a Project Segfault sysadmin you already have the password for it :P

Past this, Caddy needs to be configured.

The common GeoDNS configuration can be done following this format
```
SERVICE_NAME.{{inventory_hostname}}.projectsegfau.lt SERVICE_NAME.projectsegfau.lt SERVICE_SHORT_NAME.psf.lt SERVICE_SHORT_NAME.{{inventory_hostname}}.psf.lt {
        reverse_proxy :PORT
        import def
		import torloc SERVICE_NAME
}
```

To setup TOR, you have to add the following to privfrontends/templates/eu/darknet.Caddy
```
http://SERVICE_NAME.pjsfkvpxlinjamtawaksbnnaqs2fc2mtvmozrzckxh7f3kis6yea25ad.onion {
	import tor SERVICE_NAME
	reverse_proxy :PORT
}
```

Past this, you can run the deployment as outlined in the beginning.

Please inform me (Arya) if any part of this documentation isn't clear, I suck at writing documentation.
