# Testing ansible
```
ansible-galaxy install -r requirements.yml -p roles/galaxy/ --force
ansible-playbook playbook.yaml # Initialize
ansible-playbook -i inventory.yml -e @secrets.enc --ask-vault-pass playbooks/caddy.yaml  # Caddy
ansible-playbook -i inventory.yml -e @secrets.enc --ask-vault-pass playbooks/docker.yaml # Docker Compose
```

To add secrets: `ansible-vault edit secrets.enc`
## Per-playbook info
### /playbook.yaml
Configures basic stuff, meant for every server.
### /playbooks/docker.yaml
Configures privacy frontends, meant for US, IN and Pizza1.
### /playbooks/caddy.yaml
Configures Caddy, meant for US, IN and Pizza1.
## Adding new services
Adding new services is a bit janky, for I had to set it up with normal commands instead of the preferred community.docker collection (it doesn't support v2 which we use on most of our compose files)

Firstly, add the thing to `docker_services` array/var in `/playbooks/docker.yaml`. This list **MUST** be maintaind in alphabetical order for ease of maintanence.

Then, create the `/compose/SERVICE_NAME` directory and add the compose file to the same. You can use the `{{inventory_hostname}}` variables where required.

If the service needs a secret key, add it to the ansible-vault secrets.enc with `ansible-vault edit secrets.enc`. If you are a Project Segfault sysadmin you already have the password for it :P

Past this, Caddy needs to be configured.

The common GeoDNS configuration can be done following this format
```
SERVICE_NAME.{{inventory_hostname}}.projectsegfau.lt SERVICE_NAME.projectsegfau.lt {
        reverse_proxy :PORT
        import def
		import torloc SERVICE_NAME # Setup tor first following the wiki
}
```

Tor/I2P can be setup following the instructions in https://wiki.projectsegfau.lt/Internal:Setting_up_a_GeoDNS_service, with the only change that tor/i2p are now merged and they are in `/templates/01-extras.caddy`.

Past this, you can run the deployment as outlined in the beginning.

Please inform me (Arya) if any part of this documentation isn't clear, I suck at writing documentation.
