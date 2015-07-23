ansistrano-symfony-deploy
=========

A set of [Ansible](http://docs.ansible.com/) tasks for deploying PHP applications developed using the Symfony framework onto *nix servers in a "Capistrano" fashion (releases, shared, current->releases/X).

This role is more or less just a collection of the most common post-installation setup tasks (i.e. getting a Composer executable, installing dependencies and autoloader, perform cache warming, deploy migrations etc). It does not itself deal with setting up the directory structures or getting files onto your servers - that part is handled by the more generic `ansistrano-deploy` role.

The way this is implemented is by defining a couple of the `ansistrano_(before|after)_X` vars (see the [ansistrano docs](https://github.com/ansistrano/deploy#main-workflow) for details).

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

symfony_run_doctrine_migrations: true
symfony_doctrine_options: '--no-interaction'
```

In addition to this, please also refer to the [list of variables used by ansistrano](https://github.com/ansistrano/deploy#role-variables).

Dependencies
------------

- [carlosbuenosvinos.ansistrano-deploy](https://galaxy.ansible.com/list#/roles/1387)

Invoking via `ansible-galaxy install cbrunnkvist.ansistrano-symfony-deploy` should also pull down the aforementioned role as a dependency.

As a bare minimum, you probably need to declare the `ansistrano_deploy_from` and `ansistrano_deploy_to` variables in your play.

License
-------

MIT

Author Information
------------------

- ansistrano-symfony-deploy, written by Conny Brunnkvist <cbrunnkvist@gmail.com>
- The underlying role is maintained by the `ansistrano-deploy` team
- Some code was taken from/inspiried by the `symfony2-deploy` role by the Servergrove team
