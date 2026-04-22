import { body } from "express-validator";
import { query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";

export const inventoryValidation = [
  body("itemName").trim().notEmpty(),
  body("itemType").trim().notEmpty(),
  body("quantityInStock").isFloat({ min: 0 }),
  validate
];

export const listInventory = asyncHandler(async (req, res) => {
  const rows = await query(
    `SELECT i.*, s.name AS supplier_name,
            CASE
              WHEN i.quantity_in_stock <= i.low_stock_threshold THEN 'Low'
              WHEN i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'Expiring'
              ELSE 'Healthy'
            END AS stock_status
     FROM inventory_items i
     LEFT JOIN suppliers s ON s.id = i.supplier_id
     ORDER BY i.item_name`
  );
  res.json(rows);
});

export const createInventoryItem = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await query(
    `INSERT INTO inventory_items (
      item_name, item_type, batch_number, cost_per_unit, selling_price, quantity_in_stock,
      unit, expiry_date, supplier_id, storage_location, low_stock_threshold
    ) VALUES (
      :itemName, :itemType, :batchNumber, :costPerUnit, :sellingPrice, :quantityInStock,
      :unit, :expiryDate, :supplierId, :storageLocation, :lowStockThreshold
    )`,
    {
      itemName: payload.itemName,
      itemType: payload.itemType,
      batchNumber: payload.batchNumber || null,
      costPerUnit: payload.costPerUnit || 0,
      sellingPrice: payload.sellingPrice || 0,
      quantityInStock: payload.quantityInStock,
      unit: payload.unit || "ml",
      expiryDate: payload.expiryDate || null,
      supplierId: payload.supplierId || null,
      storageLocation: payload.storageLocation || null,
      lowStockThreshold: payload.lowStockThreshold || 10
    }
  );

  res.status(201).json({ message: "Inventory item added", id: result.insertId });
});
