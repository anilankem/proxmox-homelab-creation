# proxmox-homelab-creation

### Proxmox + Terraform + GitHub Actions VM automation

This repo provisions and destroys Proxmox VMs from a template using Terraform, driven by a GitHub Actions workflow with a simple form (dropdowns and text fields).

---

### Proxmox prerequisites

- **Proxmox node**
  - At least one node that will host the VMs (for example: `pve`).
- **VM templates**
  - One or more Proxmox VM templates with cloud-init enabled (for example: `ubuntu-22-template`, `debian-12-template`).
  - Templates should be fully configured base images you want to clone from.
- **Storage**
  - A disk storage ID for VM disks (for example: `local-lvm`).
  - Optional separate storage for ISO/templates if your setup uses it.

### Proxmox API user and token

1. **Create a dedicated user**
   - In the Proxmox web UI, go to **Datacenter → Permissions → Users**.
   - Create a user, for example: `terraform@pve` (realm can be `pve` or another you prefer).
2. **Create or assign a role**
   - Ensure the user has a role allowing it to:
     - Clone VMs from templates.
     - Start, stop, and delete VMs.
     - Access the node and storage where VMs will live.
   - You can use an existing role such as `PVEAdmin`, or create a custom role with the needed privileges only.
3. **Create an API token for the user**
   - Go to **Datacenter → Permissions → API Tokens** (or via the user detail page).
   - Create a token for `terraform@pve`, for example with ID `github`.
   - Note the resulting:
     - **Token ID** (for example: `terraform@pve!github`).
     - **Secret** (the token secret value) — store this securely and do not commit it.
4. **Find your Proxmox API URL**
   - Typical pattern: `https://<your-proxmox-host>:8006/api2/json`
   - Example: `https://proxmox.example.com:8006/api2/json`

### GitHub secrets required

In your GitHub repository, go to **Settings → Secrets and variables → Actions → New repository secret** and create:

- **`PROXMOX_API_URL`**
  - Value: your Proxmox API base URL (for example `https://proxmox.example.com:8006/api2/json`).
- **`PROXMOX_TOKEN_ID`**
  - Value: your token ID (for example `terraform@pve!github`).
- **`PROXMOX_TOKEN_SECRET`**
  - Value: the token secret string shown when you created the API token.
- (Optional) **`PROXMOX_INSECURE`**
  - Value: `true` if you want Terraform to skip TLS certificate verification (for self-signed certs). Otherwise you can leave this unset or set to `false`.

These values are read by Terraform via the GitHub Actions workflow and are **never** committed to the repository.

---

### How to use the GitHub workflow

1. **Ensure prerequisites are ready**
   - Proxmox templates exist and match the names configured in `.github/workflows/proxmox-vm.yml` under the `template` input options.
   - GitHub secrets `PROXMOX_API_URL`, `PROXMOX_TOKEN_ID`, `PROXMOX_TOKEN_SECRET` (and optionally `PROXMOX_INSECURE`) are configured.
2. **Trigger the workflow**
   - In your GitHub repository, open the **Actions** tab.
   - Select **“Proxmox VM create/destroy”** in the left sidebar.
   - Click **“Run workflow”**.
3. **Fill in the form inputs**
   - **action**: choose `create` or `destroy`.
   - **template**: pick the template to clone from (for example `ubuntu-22-template`).
   - **vm_name**: set the name of the VM in Proxmox.
   - **ram_mb**: RAM in megabytes (for example `2048` for 2 GB).
   - **disk_gb**: Disk size in gigabytes (for example `20`).
   - **node_name**: Proxmox node name (for example `pve`).
4. **Create a VM**
   - Set **action** to `create` and submit the workflow.
   - GitHub Actions will run `terraform init` and `terraform apply` in `proxmox/terraform`, creating a VM that clones your chosen template with the specified RAM and disk size.
   - On success, the `terraform output` step will show the created VM ID in the workflow logs.
5. **Destroy a VM**
   - To destroy the same VM, re-run the workflow with:
     - **action**: `destroy`
     - The same **vm_name**, **template**, **node_name**, and (ideally) the same `ram_mb` and `disk_gb` values used for creation.
   - Terraform will use that configuration and run `terraform destroy` against the matching resource, removing the VM from Proxmox.