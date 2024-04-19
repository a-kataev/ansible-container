# ansible-container

Container image for [ansible](https://github.com/ansible/ansible).

## Usage

Clone repository

```shell
$ git clone git@github.com:a-kataev/ansible-container.git
$ cd ansible-container
```

Build a new image

```shell
$ docker build \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg ANSIBLE_CORE_VERSION=2.16.4 \
  -f alpine.Containerfile \
  -t ansible-container \
  .
```

Run a container from new image

```shell
$ docker run --name ansible --rm -it ansible-container ansible-playbook --version
start ssh-agent
ansible-playbook [core 2.16.4]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.12/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible-playbook
  python version = 3.12.2 (main, Mar 16 2024, 08:59:06) [GCC 13.2.1 20231014] (/usr/local/bin/python)
  jinja version = 3.1.3
  libyaml = False
stop ssh-agent
exit code 0
```

More examples in [examples](examples)
