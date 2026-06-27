

-- Drop existing tables safely (correct dependency order)
DROP TABLE IF EXISTS store_performance CASCADE;
DROP TABLE IF EXISTS marketing_campaigns CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS revenue CASCADE;
DROP TABLE IF EXISTS sales_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS cities CASCADE;

-- 1. cities
CREATE TABLE cities (
  city_id   SERIAL PRIMARY KEY,
  city_name VARCHAR(100) NOT NULL,
  state     VARCHAR(100) NOT NULL,
  region    VARCHAR(50)  NOT NULL,
  tier      VARCHAR(20)  NOT NULL
);

-- 2. stores
CREATE TABLE stores (
  store_id         SERIAL PRIMARY KEY,
  store_code       VARCHAR(20)  UNIQUE NOT NULL,
  store_name       VARCHAR(150) NOT NULL,
  city_id          INTEGER REFERENCES cities(city_id),
  address          TEXT,
  opening_date     DATE NOT NULL,
  store_type       VARCHAR(30)  NOT NULL,
  is_active        BOOLEAN DEFAULT TRUE,
  seating_capacity INTEGER,
  manager_name     VARCHAR(100)
);

-- 3. customers
CREATE TABLE customers (
  customer_id        SERIAL PRIMARY KEY,
  customer_name      VARCHAR(150) NOT NULL,
  email              VARCHAR(200) UNIQUE,
  phone              VARCHAR(20),
  city_id            INTEGER REFERENCES cities(city_id),
  gender             VARCHAR(10),
  age_group          VARCHAR(20),
  loyalty_tier       VARCHAR(20) DEFAULT 'Bronze',
  joined_date        DATE NOT NULL,
  is_repeat_customer BOOLEAN DEFAULT FALSE,
  total_orders       INTEGER DEFAULT 0,
  total_spent        NUMERIC(12,2) DEFAULT 0
);

-- 4. products
CREATE TABLE products (
  product_id   SERIAL PRIMARY KEY,
  product_name VARCHAR(150) NOT NULL,
  category     VARCHAR(50)  NOT NULL,
  sub_category VARCHAR(50),
  base_price   NUMERIC(8,2) NOT NULL,
  cost_price   NUMERIC(8,2) NOT NULL,
  is_vegetarian BOOLEAN DEFAULT TRUE,
  is_active    BOOLEAN DEFAULT TRUE
);

-- 5. sales
CREATE TABLE sales (
  sale_id            SERIAL PRIMARY KEY,
  order_date         DATE NOT NULL,
  store_id           INTEGER REFERENCES stores(store_id),
  customer_id        INTEGER REFERENCES customers(customer_id),
  order_channel      VARCHAR(30) NOT NULL,
  order_type         VARCHAR(20) NOT NULL,
  total_amount       NUMERIC(10,2) NOT NULL,
  discount_amount    NUMERIC(8,2) DEFAULT 0,
  net_amount         NUMERIC(10,2) NOT NULL,
  payment_method     VARCHAR(30),
  is_repeat_order    BOOLEAN DEFAULT FALSE,
  delivery_time_mins INTEGER,
  rating             NUMERIC(3,1)
);

-- 6. sales_items
CREATE TABLE sales_items (
  item_id      SERIAL PRIMARY KEY,
  sale_id      INTEGER REFERENCES sales(sale_id),
  product_id   INTEGER REFERENCES products(product_id),
  quantity     INTEGER NOT NULL,
  unit_price   NUMERIC(8,2) NOT NULL,
  discount_pct NUMERIC(5,2) DEFAULT 0,
  line_total   NUMERIC(10,2) NOT NULL
);

-- 7. revenue
CREATE TABLE revenue (
  revenue_id           SERIAL PRIMARY KEY,
  store_id             INTEGER REFERENCES stores(store_id),
  month                INTEGER NOT NULL,
  year                 INTEGER NOT NULL,
  total_revenue        NUMERIC(14,2) NOT NULL,
  total_orders         INTEGER NOT NULL,
  avg_order_value      NUMERIC(8,2),
  dine_in_revenue      NUMERIC(12,2) DEFAULT 0,
  delivery_revenue     NUMERIC(12,2) DEFAULT 0,
  online_revenue       NUMERIC(12,2) DEFAULT 0,
  total_discount_given NUMERIC(10,2) DEFAULT 0,
  net_profit           NUMERIC(12,2),
  UNIQUE (store_id, month, year)
);

-- 8. inventory
CREATE TABLE inventory (
  inventory_id   SERIAL PRIMARY KEY,
  store_id       INTEGER REFERENCES stores(store_id),
  product_id     INTEGER REFERENCES products(product_id),
  record_date    DATE NOT NULL,
  opening_stock  INTEGER NOT NULL,
  received_stock INTEGER DEFAULT 0,
  consumed_stock INTEGER DEFAULT 0,
  wasted_stock   INTEGER DEFAULT 0,
  closing_stock  INTEGER NOT NULL,
  reorder_level  INTEGER DEFAULT 10,
  unit           VARCHAR(20)
);

-- 9. marketing_campaigns
CREATE TABLE marketing_campaigns (
  campaign_id        SERIAL PRIMARY KEY,
  campaign_name      VARCHAR(200) NOT NULL,
  campaign_type      VARCHAR(50)  NOT NULL,
  platform           VARCHAR(50),
  start_date         DATE NOT NULL,
  end_date           DATE NOT NULL,
  budget_spent       NUMERIC(12,2) NOT NULL,
  target_region      VARCHAR(50),
  target_city_id     INTEGER REFERENCES cities(city_id),
  target_tier        VARCHAR(20),
  impressions        BIGINT DEFAULT 0,
  clicks             BIGINT DEFAULT 0,
  conversions        INTEGER DEFAULT 0,
  revenue_attributed NUMERIC(12,2) DEFAULT 0,
  roi                NUMERIC(8,2),
  campaign_status    VARCHAR(20) DEFAULT 'Completed'
);

-- 10. store_performance
CREATE TABLE store_performance (
  perf_id                SERIAL PRIMARY KEY,
  store_id               INTEGER REFERENCES stores(store_id),
  week_start             DATE NOT NULL,
  week_end               DATE NOT NULL,
  total_orders           INTEGER NOT NULL,
  total_revenue          NUMERIC(12,2) NOT NULL,
  avg_rating             NUMERIC(3,2),
  repeat_customer_count  INTEGER DEFAULT 0,
  new_customer_count     INTEGER DEFAULT 0,
  cancellation_count     INTEGER DEFAULT 0,
  avg_delivery_time_mins NUMERIC(5,1),
  employee_count         INTEGER,
  target_revenue         NUMERIC(12,2),
  achievement_pct        NUMERIC(5,2),
  UNIQUE (store_id, week_start)
);
