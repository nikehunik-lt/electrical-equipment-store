CREATE TABLE "dim_date" (
  "date_key" int PRIMARY KEY,
  "full_date" date NOT NULL,
  "day" int NOT NULL,
  "month" int NOT NULL,
  "month_name" varchar(20) NOT NULL,
  "quarter" int NOT NULL,
  "year" int NOT NULL,
  "day_of_week" varchar(20) NOT NULL
);

CREATE TABLE "dim_customer" (
  "customer_key" serial PRIMARY KEY,
  "customer_id" int NOT NULL,
  "first_name" varchar(50) NOT NULL,
  "last_name" varchar(50) NOT NULL,
  "email" varchar(100) NOT NULL,
  "city" varchar(50),
  "country" varchar(100),
  "start_date" timestamp NOT NULL DEFAULT (now()),
  "end_date" timestamp,
  "is_current" boolean NOT NULL DEFAULT true
);

CREATE TABLE "dim_product" (
  "product_key" serial PRIMARY KEY,
  "product_id" int NOT NULL,
  "name" varchar(200) NOT NULL,
  "sku" varchar(50) NOT NULL,
  "price" numeric(10,2) NOT NULL,
  "cost" numeric(10,2) NOT NULL,
  "category_id" int,
  "brand_id" int,
  "start_date" timestamp NOT NULL DEFAULT (now()),
  "end_date" timestamp,
  "is_current" boolean NOT NULL DEFAULT true
);

CREATE TABLE "dim_category" (
  "category_key" serial PRIMARY KEY,
  "category_id" int NOT NULL,
  "name" varchar(100) NOT NULL,
  "description" text
);

CREATE TABLE "dim_brand" (
  "brand_key" serial PRIMARY KEY,
  "brand_id" int NOT NULL,
  "name" varchar(100) NOT NULL,
  "country" varchar(100)
);

CREATE TABLE "dim_employee" (
  "employee_key" serial PRIMARY KEY,
  "employee_id" int NOT NULL,
  "first_name" varchar(50) NOT NULL,
  "last_name" varchar(50) NOT NULL,
  "position" varchar(50),
  "hire_date" date
);

CREATE TABLE "dim_supplier" (
  "supplier_key" serial PRIMARY KEY,
  "supplier_id" int NOT NULL,
  "name" varchar(150) NOT NULL,
  "city" varchar(50),
  "country" varchar(100)
);

CREATE TABLE "fact_sales" (
  "sales_key" serial PRIMARY KEY,
  "date_key" int,
  "customer_key" int,
  "product_key" int,
  "employee_key" int,
  "order_id" int NOT NULL,
  "quantity" int NOT NULL,
  "unit_price" numeric(10,2) NOT NULL,
  "discount" numeric(5,2) DEFAULT 0,
  "total_amount" numeric(12,2) NOT NULL,
  "profit" numeric(12,2) NOT NULL
);

CREATE TABLE "fact_inventory" (
  "inventory_key" serial PRIMARY KEY,
  "date_key" int,
  "product_key" int,
  "supplier_key" int,
  "stock_quantity" int NOT NULL,
  "stock_value" numeric(12,2) NOT NULL
);

CREATE TABLE "bridge_product_supplier" (
  "bridge_key" serial PRIMARY KEY,
  "product_key" int,
  "supplier_key" int,
  "supply_price" numeric(10,2),
  "lead_time_days" int
);

ALTER TABLE "dim_product" ADD FOREIGN KEY ("category_id") REFERENCES "dim_category" ("category_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "dim_product" ADD FOREIGN KEY ("brand_id") REFERENCES "dim_brand" ("brand_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("date_key") REFERENCES "dim_date" ("date_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("customer_key") REFERENCES "dim_customer" ("customer_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("product_key") REFERENCES "dim_product" ("product_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("employee_key") REFERENCES "dim_employee" ("employee_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_inventory" ADD FOREIGN KEY ("date_key") REFERENCES "dim_date" ("date_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_inventory" ADD FOREIGN KEY ("product_key") REFERENCES "dim_product" ("product_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fact_inventory" ADD FOREIGN KEY ("supplier_key") REFERENCES "dim_supplier" ("supplier_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "bridge_product_supplier" ADD FOREIGN KEY ("product_key") REFERENCES "dim_product" ("product_key") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "bridge_product_supplier" ADD FOREIGN KEY ("supplier_key") REFERENCES "dim_supplier" ("supplier_key") DEFERRABLE INITIALLY IMMEDIATE;
