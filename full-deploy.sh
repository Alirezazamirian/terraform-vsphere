#!/usr/bin/env bash
set -euo pipefail

echo "============================================"
echo "🚀 Starting RnD-MCI Deployment Pipeline"
echo "============================================"
echo "This script runs the both runs at once with 15 min pause for creating of vm-template CL item manually between runs."
# ==================== PREREQUISITES ====================
echo "→ Applying prerequisites..."
pushd prereq >/dev/null
terraform init -upgrade
echo "This is a brief plan of what Terraform is going to do for first run :"
terraform plan
read -p "Press Enter after you read the full changes ..."
terraform apply -auto-approve
popd >/dev/null

echo "✅ Prerequisites completed."

# ==================== MANUAL / WAIT GAP ====================
echo "⏳ Waiting 15 minutes for manual steps / vSphere stabilization..."
sleep 900   # 15 minutes

# Optional: add a prompt so you don't forget to do the manual work
read -p "Press Enter after you finished the manual vSphere steps..."

# ==================== DEPLOYMENT ====================
echo "→ Applying main deployment..."
pushd deployment >/dev/null
terraform init -upgrade
echo "This is a brief plan of what Terraform is going to do for second run :"
terraform plan
read -p "Press Enter after you read the full changes ..."
terraform apply -auto-approve
popd >/dev/null

echo "🎉 Full deployment completed!"
