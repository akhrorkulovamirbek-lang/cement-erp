-- Справочники

CREATE TABLE IF NOT EXISTS zavody (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS clients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cement_marks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS machines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number TEXT NOT NULL UNIQUE,
  own BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Брокерский счет
CREATE TABLE IF NOT EXISTS broker_account (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  balance REAL DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- История операций на брокерском счете
CREATE TABLE IF NOT EXISTS broker_operations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  type TEXT NOT NULL, -- 'пополнение', 'закупка_тикета', 'возврат'
  amount REAL NOT NULL,
  description TEXT,
  related_ticket_id INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Тикеты (активы биржи)
CREATE TABLE IF NOT EXISTS tickets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticket_number TEXT NOT NULL UNIQUE,
  zavod_id INTEGER NOT NULL,
  cement_mark_id INTEGER NOT NULL,
  bought_tonnage REAL NOT NULL,
  price_per_ton REAL NOT NULL,
  bought_sum REAL NOT NULL,
  remaining_tonnage REAL NOT NULL,
  remaining_sum REAL NOT NULL,
  status TEXT DEFAULT 'active', -- 'active', 'on_return', 'closed'
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (zavod_id) REFERENCES zavody(id),
  FOREIGN KEY (cement_mark_id) REFERENCES cement_marks(id)
);

-- Приход (закупка на склад)
CREATE TABLE IF NOT EXISTS incoming (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  machine_number TEXT,
  cement_mark_id INTEGER NOT NULL,
  type TEXT NOT NULL, -- 'рассыпной', 'мешок'
  tonnage REAL NOT NULL,
  price_per_ton REAL NOT NULL,
  total_sum REAL NOT NULL,
  warehouse_received BOOLEAN DEFAULT 1, -- пришел ли в базу
  zavod_id INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cement_mark_id) REFERENCES cement_marks(id),
  FOREIGN KEY (zavod_id) REFERENCES zavody(id)
);

-- Остатки склада (пересчитывается на основе приходов и продаж)
CREATE TABLE IF NOT EXISTS warehouse_balance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cement_mark_id INTEGER NOT NULL,
  type TEXT NOT NULL, -- 'рассыпной', 'мешок'
  tonnage REAL DEFAULT 0,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cement_mark_id) REFERENCES cement_marks(id),
  UNIQUE(cement_mark_id, type)
);

-- Продажи
CREATE TABLE IF NOT EXISTS sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  client_id INTEGER NOT NULL,
  cement_mark_id INTEGER NOT NULL,
  type TEXT NOT NULL, -- 'рассыпной', 'мешок'
  tonnage REAL NOT NULL,
  price_per_ton REAL NOT NULL,
  total_sum REAL NOT NULL,
  source TEXT NOT NULL, -- 'warehouse', 'ticket'
  warehouse_or_zavod TEXT, -- 'warehouse' или имя завода
  ticket_id INTEGER, -- если source='ticket'
  has_logistics BOOLEAN DEFAULT 0,
  machine_number TEXT,
  machine_own BOOLEAN,
  logistics_price_per_ton REAL,
  logistics_total REAL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES clients(id),
  FOREIGN KEY (cement_mark_id) REFERENCES cement_marks(id),
  FOREIGN KEY (ticket_id) REFERENCES tickets(id)
);

-- Логистика (самостоятельные услуги перевозки)
CREATE TABLE IF NOT EXISTS logistics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  machine_number TEXT NOT NULL,
  machine_own BOOLEAN DEFAULT 1,
  tonnage REAL NOT NULL,
  price_per_ton REAL NOT NULL,
  total_sum REAL NOT NULL,
  client_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- Касса - Приход
CREATE TABLE IF NOT EXISTS cash_income (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  category TEXT NOT NULL, -- 'цемент', 'логистика', 'возврат_биржи'
  client_id INTEGER,
  amount REAL NOT NULL,
  currency TEXT DEFAULT 'USD',
  usd_rate REAL DEFAULT 1,
  payment_type TEXT NOT NULL, -- 'перечисление', 'наличка', 'карта'
  comment TEXT,
  related_sale_id INTEGER,
  related_broker_op_id INTEGER, -- для возврата биржи
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES clients(id),
  FOREIGN KEY (related_sale_id) REFERENCES sales(id)
);

-- Касса - Расход
CREATE TABLE IF NOT EXISTS cash_expense (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  category TEXT NOT NULL, -- 'цемент', 'логистика'
  machine_number TEXT, -- если логистика
  expense_type TEXT, -- 'газ', 'запчасть', 'зп', 'обед'
  amount REAL NOT NULL,
  currency TEXT DEFAULT 'UZS',
  payment_type TEXT NOT NULL, -- 'наличка', 'перечисление', 'карта'
  comment TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
