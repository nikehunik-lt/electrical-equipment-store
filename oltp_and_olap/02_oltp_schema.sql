CREATE TABLE "categories" (
  "category_id" serial PRIMARY KEY,
  "name" varchar(100) UNIQUE NOT NULL,
  "description" text,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "brands" (
  "brand_id" serial PRIMARY KEY,
  "name" varchar(100) UNIQUE NOT NULL,
  "country" varchar(100),
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "suppliers" (
  "supplier_id" serial PRIMARY KEY,
  "name" varchar(150) NOT NULL,
  "contact_name" varchar(100),
  "email" varchar(100) UNIQUE,
  "phone" varchar(50),
  "address" text,
  "city" varchar(50),
  "country" varchar(100),
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "products" (
  "product_id" serial PRIMARY KEY,
  "name" varchar(200) NOT NULL,
  "description" text,
  "sku" varchar(50) UNIQUE NOT NULL,
  "category_id" int,
  "brand_id" int,
  "supplier_id" int,
  "price" numeric(10,2) NOT NULL,
  "cost" numeric(10,2) NOT NULL,
  "stock_quantity" int DEFAULT 0,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "customers" (
  "customer_id" serial PRIMARY KEY,
  "first_name" varchar(50) NOT NULL,
  "last_name" varchar(50) NOT NULL,
  "email" varchar(100) UNIQUE NOT NULL,
  "phone" varchar(50),
  "address" text,
  "city" varchar(50),
  "country" varchar(100),
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "employees" (
  "employee_id" serial PRIMARY KEY,
  "first_name" varchar(50) NOT NULL,
  "last_name" varchar(50) NOT NULL,
  "email" varchar(100) UNIQUE NOT NULL,
  "phone" varchar(50),
  "position" varchar(50),
  "hire_date" date NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "orders" (
  "order_id" serial PRIMARY KEY,
  "customer_id" int,
  "employee_id" int,
  "order_date" timestamp NOT NULL DEFAULT (now()),
  "status" varchar(20) DEFAULT 'pending',
  "total_amount" numeric(12,2) DEFAULT 0,
  "shipping_address" text,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "order_items" (
  "order_item_id" serial PRIMARY KEY,
  "order_id" int,
  "product_id" int,
  "quantity" int NOT NULL,
  "unit_price" numeric(10,2) NOT NULL,
  "discount" numeric(5,2) DEFAULT 0,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "payments" (
  "payment_id" serial PRIMARY KEY,
  "order_id" int,
  "payment_date" timestamp NOT NULL DEFAULT (now()),
  "amount" numeric(12,2) NOT NULL,
  "payment_method" varchar(30) NOT NULL,
  "status" varchar(20) DEFAULT 'completed',
  "created_at" timestamp DEFAULT (now())
);

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("supplier_id") REFERENCES "suppliers" ("supplier_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("employee_id") REFERENCES "employees" ("employee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;
