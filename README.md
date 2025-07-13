# Ace Hardware Relational Database System

This project is a comprehensive relational database system designed for **Ace Hardware**, focused on managing product inventory, customer orders, warehouse logistics, and delivery mechanisms. It includes support for both **local** and **third-party deliveries**, real-time truck tracking, stock management, and stored procedures for delivery operations.

---

## 📁 Project Contents

- `Team5ACE_DBbackup.sql`: Full SQL dump of the Ace_Hardware database.
- Database includes:
  - Normalized schema
  - Data insertions for testing
  - Stored procedures
  - Triggers
  - Foreign key constraints

---

## 🧱 Database Schema Overview

The database consists of the following key entities:

- **Customer**: Customer profiles with address and postal info
- **Product**: Hardware items with product details and pricing
- **Warehouse**: Storage locations with delivery radii
- **OrderHeader** & **OrderLine**: Support for orders and order details
- **DeliveryOrder**: Tracks whether the delivery is local or third-party
- **DeliveryTruck**: Manages local delivery trucks and their status/capacity
- **LocalDelivery** & **ThirdPartyDelivery**: Handles delivery modes
- **Carrier**: Third-party delivery services (e.g., FedEx, DHL)
- **Stock**: Inventory levels of products at each warehouse
- **RealTimeTracking**: GPS tracking of delivery trucks
- **Route**: Distance mapping from warehouse to customer

---

## ⚙️ Features

- ✅ Normalized relational database design
- 🚛 Automatic truck assignment via stored procedure: `AssignPendingDeliveries`
- 📍 Real-time delivery tracking with trigger: `ArchiveOldGPSData`
- 📦 Inventory tracking per warehouse
- 🔐 Referential integrity using foreign keys
- 🚨 Capacity validation via trigger: `ValidateTruckCapacity`

---

## 🛠️ Setup Instructions

1. Install MySQL (version 8.0+ recommended)
2. Use phpMyAdmin or MySQL CLI to import the SQL file:
   ```bash
   mysql -u root -p < Team5ACE_DBbackup.sql
