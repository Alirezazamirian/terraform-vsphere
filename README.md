# Terraform vSphere Infrastructure (Air-Gapped Datacenter)

## Overview

This repository contains **Terraform configurations** for provisioning and managing VMware vSphere infrastructure in **air-gapped** environments (`dev`, `stage`, `prod`).

> ⚠️ **Caution – Air-gapped environment is guided at end of this README**  
> No internet access is allowed in an air-gapped environment.  
> → The VMware vSphere provider **must be pre-downloaded** and placed in a local mirror or project directory before running `terraform init` in thesecases.

> ⚠️ **Important – Not greenfield**  
> This project **does not create** the datacenter, clusters, ESXi hosts, datastores or basic networking from scratch.
> The ESXI hosts joining actions, datatcenter definition, datastores definition, and networking should be implemented by IT infrastructure team.  
> It assumes these foundational objects already exist.

Main goals:

- Create / manage **VM templates** (via cloning + customization)
- Deploy **VM clusters** from those templates
- Create **resource pools** and **content libraries** when needed
- Support **multi-environment** setups with different workflows

---

## Prerequisites & Required Knowledge

To fully leverage this repository and understand its design, implementation patterns, and intended workflows, users should have a solid working knowledge of:

- cloud-init configuration syntax, schema structure, and practical use cases
- VMware vCenter / vSphere (ESXi 7.x and 8.x) architecture and operational concepts
- The Terraform `vmware/vsphere` (HashiCorp) provider, including cloning, customization, content libraries, and remote state usage

This project assumes familiarity with these technologies. Without that foundation, it may be difficult to correctly interpret, extend, or troubleshoot the infrastructure logic implemented here.

---

## Current Repository Structure (2026)

```text
terraform-vsphere/
    ├── deployment                    # Phase 2 – main VM provisioning
    │   ├── backend.tf
    │   ├── data-modules
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   ├── main.tf
    │   ├── output.tf
    │   ├── provisioning
    │   │   ├── cloud-init.tftpl
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    ├── full-deploy.sh                # Orchestrates both phases + pause
    ├── prereq                        # Phase 1 – templates, pools, libraries
    │   ├── backend.tf
    │   ├── data-modules
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   ├── main.tf
    │   ├── output.tf
    │   ├── provisioning
    │   │   ├── cloud-init.tftpl
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   ├── resource-modules
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── README.md
```

# vSphere Terraform Examples & Patterns

## Environments / Folders Overview

- **`terraform-vsphere`**  
  Two-phase approach (recommended for production-like, with capability of air-gapped setups)

  - `prereq/` → prepares templates, folders, resource pools, content libraries  
  - `deployment/` → clones / deploys final application VMs from prepared templates

## Key Concepts & Folders

| Folder / Module              | Purpose                                                                 | Phase (RnD-MCI)     |
|------------------------------|-------------------------------------------------------------------------|---------------------|
| `data-modules/`              | Read-only data sources (datacenter, cluster, hosts, networks, datastores, CL items…) | both                |
| `resource-modules/`          | Creates new resource pools & content libraries (only when configured)   | prereq              |
| `provisioning/` (in prereq)  | Creates VM templates from existing VMs (cloning + cloud-init)          | prereq              |
| `provisioning/` (in deployment) | Deploys final VM clusters from templates (with per-VM IPs, disks, cloud-init) | deployment          |
| `prereq/`                    | Phase 1 – infrastructure preparation (RnD-MCI style)                   | prereq        |
| `deployment/`                | Phase 2 – application / service VMs                                     | deployment        |

## Two-Phase Workflow – (recommended pattern)

Most production-like folders, use **two Terraform runs** with a **manual intervention pause** in between.

### 1. Phase 1 – `prereq/`

- Fetches existing objects
- Creates missing folders, resource pools, content libraries
- Clones selected base VMs → creates new named VMs (future templates)
- **Output**: state file with IDs + prepared-but-not-yet-templated VMs

### 2. Manual pause (most important step!)

You **must** perform these actions in the vSphere Client before Phase 2:

- Locate all VMs created in Phase 1 (they are normal VMs, not templates yet)
- For each VM do **one** of the following:

  - Right-click → **Template** → **Convert to Template**  
    **OR** (preferred)
  - Right-click → **Template** → **Export as Template** into the target Content Library
    - Recommended type: **VM Template** (not OVF)
    - Target Content Library: the one defined in `vm_base_template.library_name`

- Wait until the task completes and the items appear as type `vm-template` in the Content Library

### 3. Phase 2 – `deployment/`

- Reads Phase 1 outputs (via `terraform_remote_state`)
- Looks up template UUIDs in Content Library (or falls back to VM UUID if still missing)
- Clones final application VMs from those templates
- Applies per-node IPs, hostnames, extra disks, cloud-init, folders…

### Recommended way to run both phases

after cloning:
```bash
cd terraform-vsphere/
./full-deploy.sh
```

- The script:

   - runs phase 1
   - waits 15 minutes (configurable)
   - shows reminder prompt
   - runs phase 2

# Phase 1
```bash
cd prereq
terraform init -upgrade
terraform apply
```

# → do the manual template conversion in vSphere ←

# Phase 2
```bash
cd ../deployment
terraform init -upgrade
terraform apply
```

## Air-Gapped Provider Setup
#### The VMware vSphere provider must be available offline.
##### Recommended locations (checked in this order):
1. Project-local mirror (most convenient)
```text
terraform/
└── .terraform/
    └── providers/
        └── registry.terraform.io/
            └── vmware/
                └── vsphere/
                    └── 2.15.0/
                        └── linux_amd64/
                            └── terraform-provider-vsphere_v2.15.0_x5
```
2. Global user mirror
##### Recommended location to accommodate the terraform provider binary(binary installed from vmware official github page):
```text
~/.terraform.d/plugins/registry.terraform.io/vmware/vsphere/2.15.0/linux_amd64/...
```

Required ~/.terraformrc (or terraform.rc on Windows):
```text
provider_installation {
  filesystem_mirror {
    path    = "/home/<user>/.terraform.d/plugins"
    include = ["registry.terraform.io/vmware/vsphere"]
  }

  direct {
    exclude = ["registry.terraform.io/vmware/vsphere"]
  }
}
```

## Next Steps & Manual Actions Summary

To successfully use this repository:

1. **Prepare your environment**  
   Keep base VMs or OVFs already uploaded and ready in vSphere.

2. **Configure new templates**  
   Edit `prereq/variables.tf` and define your desired templates in the `vm_base_template` block.

3. **Complete Phase 1 manual step**  
   After running `terraform apply` in the `prereq/` folder:  
   Convert or export the newly created VMs into **VM Templates** in the target Content Library (via vSphere Client).

4. **Adjust timeouts (if necessary)**  
   For VMs with large disks or slow environments, consider increasing:  
   - `general_vm_cloning_timeout`  
   - `general_customize_vm_timeout`

5. **Deploy with the helper script** (recommended)  
   For new folders that you may demand to create/extend the current project, simply copy and paste the file/folder format directory, and make the whole current setup as a sub-directory, then run(for ex.):
   ```bash
   cd terraform-vsphere/prod/
   ./full-deploy.sh
   ```
   Or:
   ```bash
   cd terraform-vsphere/stage/
   ./full-deploy.sh
   ```

   Comprehensively, you can name the foders whatever you want to form a multi-setup/multi-cluster implementation all on one.

Good luck with your air-gapped/public vSphere Terraform deployments! 🚀
I am open for any issue, suggestion, or colabration.


