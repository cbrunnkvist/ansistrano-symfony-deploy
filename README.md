ansistrano-symfony-deploy
=========

A set of [Ansible](http://docs.ansible.com/) tasks for deploying PHP applications developed using the Symfony framework onto *nix servers in a "Capistrano" fashion (releases, shared, current->releases/X).

This role is more or less just a collection of the most common post-installation setup tasks (i.e. getting a Composer executable, installing dependencies and autoloader, perform cache warming, deploy migrations etc). It does not itself deal with setting up the directory structures or getting files onto your servers - that part is handled by the more generic `ansistrano-deploy` role.

The way this is implemented is by defining a couple of the `ansistrano_(before|after)_X` vars (see the [ansistrano docs](https://github.com/ansistrano/deploy#main-workflow) for details).

[![Build Status](https://travis-ci.org/cbrunnkvist/ansistrano-symfony-deploy.svg?branch=master)](https://travis-ci.org/cbrunnkvist/ansistrano-symfony-deploy) 

Requirements
------------

Due to shortcomings in the current version of Ansible, it __is__ a requirement that the `ansistrano-symfony-deploy` and `ansistrano-deploy` share the same parent directory. This will be the normal case so shouldn't be an issue as long as you install via `ansible-galaxy`.

The tasks will _probably not_ work for Windows target hosts (untested).

Role Variables
--------------

The `defaults` vars declared in this module:

```YAML
symfony_env: prod
symfony_php_path: php # The PHP executable to use for all command line tasks

symfony_run_composer: true
symfony_composer_path: "{{ ansistrano_deploy_to }}/composer.phar"
symfony_composer_options: '--no-dev --optimize-autoloader --no-interaction'
symfony_composer_self_update: true # Always attempt a composer self-update

symfony_run_assets_install: true
symfony_assets_options: '--no-interaction'

symfony_run_assetic_dump: true
symfony_assetic_options: '--no-interaction'

symfony_run_cache_clear_and_warmup: true
symfony_cache_options: ''

###############################################################################
symfony_run_doctrine_migrations: false
symfony_doctrine_options: '--no-interaction'

symfony_run_mongodb_schema_update: false
symfony_mongodb_options: ''
```

In addition to this, please also refer to the [list of variables used by ansistrano](https://github.com/ansistrano/deploy#role-variables).

Note about ORM/ODM schema migrations
------------------------------------

Database schema migrations can generally NOT be run in parallel across multiple hosts! For this reason, the `symfony_run_doctrine_migrations` and `symfony_run_mongodb_schema_update` options both come turned off by default.

In order to get around the parallel exection, you can do the following:

1. Specify your own `ansistrano_before_symlink_tasks_file`, perhaps with the one in this project as a template (look in cbrunnkvist.ansistrano-symfony-deploy/config/steps/).
2. Pick one of the following approaches:
  - (a) Organize hosts into groups such that the task will run on only the _first_ host in some group:
    `when: groups['www-production'][0] == inventory_hostname`
  - (b) Use the `run_once: true` perhaps with `delegate_to: some_primary_host` ([Docs: Playbook delegation](http://docs.ansible.com/ansible/playbooks_delegation.html#run-once))

Dependencies
------------

- [carlosbuenosvinos.ansistrano-deploy](https://galaxy.ansible.com/list#/roles/1387)

Installing from the command line via `ansible-galaxy install cbrunnkvist.ansistrano-symfony-deploy` should pull down the external role as a dependency, so no extra step neccessary.

Example playbook
----------------

As a bare minimum, you probably need to declare the `ansistrano_deploy_from` and `ansistrano_deploy_to` variables in your play. Ansistrano defaults to using rsync from a local directory (again, see the [ansistrano docs](https://github.com/ansistrano/deploy)).

Let's assume there is a `my-app-infrastructure/deploy.yml`:
```YAML
---
- hosts: all
  gather_facts: false
  vars:
    ansistrano_deploy_from: ../my-project-checkout
    ansistrano_deploy_to: /home/app-user/my-project-deploy/
    ansistrano_before_symlink_tasks_file: "{{playbook_dir}}/config/app_specific_setup.yml"
  roles:
    - cbrunnkvist.ansistrano-symfony-deploy
```

This playbook should be executed like any other, i.e. `ansible-playbook -i some_hosts_file deploy.yml`.

It probably makes sense to keep your one-off system prep tasks in a separate playbook, e.g. `my-app-infrastructure/setup.yml`.

License
-------

MIT

Author Information
------------------

- ansistrano-symfony-deploy, written by Conny Brunnkvist <cbrunnkvist@gmail.com>
- The underlying role is maintained by the `ansistrano-deploy` team
- Some code was taken from/inspiried by the `symfony2-deploy` role by the Servergrove team
