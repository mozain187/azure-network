# azure-network
“Bicep code for Azure network segmentation and private endpoints.”

# 🔐 Azure Network Segmentation and Security Architecture

This project demonstrates a secure and segmented network architecture on Azure using **Bicep** infrastructure-as-code templates. The setup ensures that virtual machines securely access storage accounts through private endpoints — with carefully configured **NSG (Network Security Group) rules** and **private DNS integration**.

---

## 📊 Architecture Overview

- 🔸 **Virtual Network (`azVnet`)** with a dedicated **subnet (`azSubnet`)**
- 🔸 **Network Security Group (`azNSG`)** with:
  - Private endpoint outbound access rule for HTTPS
  - DNS traffic rule
  - Deny-all catch rule
- 🔸 **Storage Account (`azstorageacct`)**
  - Private access only via a private endpoint
  - Public access disabled
- 🔸 **Private DNS Zone**
  - Connected to the VNet for private endpoint name resolution
- 🔸 **Private Endpoint (`azPrivateEndpoint`)** with a **static private IP**

---

## 💾 Technologies Used

- 🌐 Azure Virtual Network
- 🔐 Network Security Groups
- 📦 Azure Storage Account (Blob)
- 🛰️ Azure Private Endpoint
- 🌐 Azure Private DNS Zone
- 📝 Bicep Infrastructure-as-Code

---

## 📁 Files Included

- `test.bicep` — Full deployment template
- `README.md` — Project overview and documentation

---




