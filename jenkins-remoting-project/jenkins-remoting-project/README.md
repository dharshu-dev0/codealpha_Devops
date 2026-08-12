# Task 2 — Jenkins Remoting Project

Demonstrates a Jenkins **controller** connected to isolated **remote agent
nodes**, with build load distributed across them via labels.

## Architecture

```
                    ┌─────────────────────┐
                    │  Jenkins Controller  │  :8080 (UI)  :50000 (Remoting)
                    │   (runs 0 executors) │
                    └──────────┬───────────┘
                               │ SSH (key-based auth)
                 ┌─────────────┴─────────────┐
                 ▼                             ▼
        ┌─────────────────┐           ┌─────────────────┐
        │  agent-linux     │           │  agent-test      │
        │  label: linux    │           │  label: test     │
        │  (build node)    │           │  (isolated node) │
        └─────────────────┘           └─────────────────┘
```

- The **controller runs zero executors** (`numExecutors: 0`) — it only
  schedules work, it never builds anything itself. All actual execution
  happens on remote agents. This is the core of Jenkins Remoting.
- Each agent connects over SSH using a dedicated keypair — not the
  controller's own credentials — so a compromised agent can't reach
  anything else on the controller. That's **node isolation**.
- The `Jenkinsfile` pipeline routes different stages to different labeled
  nodes, showing **load distribution** and **remote execution** in action.

## Files

```
jenkins-remoting-project/
├── docker-compose.yml         # controller + 2 remote agent containers
├── controller/
│   ├── Dockerfile             # Jenkins + plugins, JCasC enabled
│   ├── plugins.txt            # required plugin list
│   └── casc/jenkins.yaml      # Configuration-as-Code: nodes + SSH credential
├── generate-ssh-key.sh        # generates the controller↔agent SSH keypair
├── Jenkinsfile                # demo pipeline using labeled remote agents
└── ssh-keys/                  # created by generate-ssh-key.sh (gitignored)
```

## Setup

**Requirements:** Docker + Docker Compose installed and running.

```bash
cd jenkins-remoting-project

# 1. Generate the SSH keypair the controller will use to reach agents
chmod +x generate-ssh-key.sh
./generate-ssh-key.sh

# 2. Export the public key so agent containers can bake it in
export SSH_PUBKEY=$(cat ssh-keys/id_rsa.pub)

# 3. Build and start everything
docker-compose up --build
```

First build takes a few minutes (plugin install). Once up:

- Open **http://localhost:8081** (the controller's UI port 8080 is mapped
  to host port 8081 in `docker-compose.yml`)
- No initial admin password prompt — `JAVA_OPTS` disables the setup
  wizard, and the `controller/casc/jenkins.yaml` Configuration-as-Code
  file provisions the agent nodes and SSH credential automatically.
- Go to **Manage Jenkins → Nodes** — you should see `linux-agent` and
  `test-agent` listed and online. If they show as offline, give them
  ~30 seconds to connect over SSH, then refresh.

## Run the demo pipeline

1. **New Item → Pipeline**, name it `remoting-demo`.
2. Under **Pipeline**, choose **Pipeline script from SCM** if you're
   pointing at a git repo containing this `Jenkinsfile`, or paste the
   contents of `Jenkinsfile` directly into **Pipeline script**.
3. Click **Build Now**.
4. Open the build's **Console Output** — you'll see each stage report a
   different `NODE_NAME` (`linux-agent` for Build/Report, `test-agent`
   for Test), proving the work was distributed to and executed on remote,
   isolated machines.

## If the SSH agents don't auto-connect

The JCasC schema (`fileOnMasterEntry`, `nonVerifyingKeyVerificationStrategy`)
can shift slightly between plugin versions. If nodes stay offline after a
minute, fall back to manual setup:

1. **Manage Jenkins → Nodes → New Node**, create a Permanent Agent named
   `linux-agent`, label `linux`, launch method **Launch agents via SSH**,
   host `agent-linux`, and select/create the SSH credential from
   `ssh-keys/id_rsa`.
2. Repeat for `test-agent` → host `agent-test`, label `test`.

## How this maps to the task

| Requirement | Where it's demonstrated |
|---|---|
| Set up Jenkins Remoting | Controller (port 50000) + SSH-launched agent containers |
| Distribute build loads across machines securely | Two separate agent containers, SSH key auth, controller has 0 executors |
| Run jobs on various architectures | Agents are labeled independently (`linux`, `test`) — swap in real ARM/Windows hosts by pointing the SSH launcher at them |
| Improve security using node isolation | Dedicated SSH keypair per agent connection; agents don't share the controller's credential store |
| Hands-on remote execution | `Jenkinsfile` pipeline explicitly targets labels and prints `NODE_NAME` per stage |

## Note on "various architectures"

This demo runs both agent containers on the same Docker host, so they
share the same underlying CPU architecture — it demonstrates the
*mechanism* (labels routing work to specific remote nodes), not physically
different hardware. For real cross-architecture builds, point the SSH
launcher in `casc/jenkins.yaml` at actual remote machines (e.g. an ARM
Raspberry Pi or a Windows box reachable over SSH) instead of the
`agent-linux` / `agent-test` container hostnames.
