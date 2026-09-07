const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));

// Инициализация БД
const DB_FILE = 'cement_dealer.db';
let db = new sqlite3.Database(DB_FILE, (err) => {
  if (err) console.error('DB Error:', err);
  else console.log('✓ БД подключена');
});

// Инициализация схемы
const schema = fs.readFileSync('schema.sql', 'utf-8');
db.exec(schema, (err) => {
  if (err) console.error('Schema Error:', err);
  else {
    console.log('✓ Схема инициализирована');
    initializeBrokerAccount();
  }
});

// Инициализация брокерского счета (если не существует)
function initializeBrokerAccount() {
  db.get('SELECT * FROM broker_account LIMIT 1', (err, row) => {
    if (!row) {
      db.run('INSERT INTO broker_account (balance) VALUES (0)');
    }
  });
}

// Утилиты
const run = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function(err) {
      if (err) reject(err);
      else resolve({ id: this.lastID, changes: this.changes });
    });
  });
};

const get = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
};

const all = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows || []);
    });
  });
};

// ========== API ENDPOINTS ==========

// Справочники
app.get('/api/zavody', async (req, res) => {
  const data = await all('SELECT * FROM zavody');
  res.json(data);
});

app.post('/api/zavody', async (req, res) => {
  const { name } = req.body;
  const result = await run('INSERT INTO zavody (name) VALUES (?)', [name]);
  res.json(result);
});

app.get('/api/clients', async (req, res) => {
  const data = await all('SELECT * FROM clients');
  res.json(data);
});

app.post('/api/clients', async (req, res) => {
  const { name } = req.body;
  const result = await run('INSERT INTO clients (name) VALUES (?)', [name]);
  res.json(result);
});

app.get('/api/cement-marks', async (req, res) => {
  const data = await all('SELECT * FROM cement_marks');
  res.json(data);
});

app.post('/api/cement-marks', async (req, res) => {
  const { name } = req.body;
  const result = await run('INSERT INTO cement_marks (name) VALUES (?)', [name]);
  res.json(result);
});

app.get('/api/machines', async (req, res) => {
  const data = await all('SELECT * FROM machines');
  res.json(data);
});

app.post('/api/machines', async (req, res) => {
  const { number, own } = req.body;
  const result = await run('INSERT INTO machines (number, own) VALUES (?, ?)', [number, own ? 1 : 0]);
  res.json(result);
});

// Брокерский счет
app.get('/api/broker-account', async (req, res) => {
  const account = await get('SELECT * FROM broker_account LIMIT 1');
  const operations = await all('SELECT * FROM broker_operations ORDER BY date DESC LIMIT 20');
  res.json({ account, operations });
});

app.post('/api/broker-account/replenish', async (req, res) => {
  const { date, amount } = req.body;
  const account = await get('SELECT * FROM broker_account LIMIT 1');
  const newBalance = account.balance + amount;
  
  await run('UPDATE broker_account SET balance = ?, updated_at = CURRENT_TIMESTAMP', [newBalance]);
  await run('INSERT INTO broker_operations (date, type, amount, description) VALUES (?, ?, ?, ?)',
    [date, 'пополнение', amount, 'Пополнение счета']);
  
  res.json({ balance: newBalance });
});

// Тикеты
app.get('/api/tickets', async (req, res) => {
  const data = await all(`
    SELECT t.*, z.name as zavod_name, c.name as cement_mark_name
    FROM tickets t
    LEFT JOIN zavody z ON t.zavod_id = z.id
    LEFT JOIN cement_marks c ON t.cement_mark_id = c.id
    ORDER BY t.created_at DESC
  `);
  res.json(data);
});

app.post('/api/tickets', async (req, res) => {
  const { ticket_number, zavod_id, cement_mark_id, tonnage, price_per_ton } = req.body;
  const total = tonnage * price_per_ton;
  
  // Минусуем со счета
  const account = await get('SELECT * FROM broker_account LIMIT 1');
  const newBalance = account.balance - total;
  await run('UPDATE broker_account SET balance = ?', [newBalance]);
  
  // Создаем тикет
  const result = await run(`
    INSERT INTO tickets (ticket_number, zavod_id, cement_mark_id, bought_tonnage, price_per_ton, bought_sum, remaining_tonnage, remaining_sum)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `, [ticket_number, zavod_id, cement_mark_id, tonnage, price_per_ton, total, tonnage, total]);
  
  // Записываем операцию
  await run('INSERT INTO broker_operations (date, type, amount, description, related_ticket_id) VALUES (?, ?, ?, ?, ?)',
    [new Date().toISOString().split('T')[0], 'закупка_тикета', -total, `Закупка тикета ${ticket_number}`, result.id]);
  
  res.json(result);
});

// Приход
app.get('/api/incoming', async (req, res) => {
  const data = await all(`
    SELECT i.*, c.name as cement_mark_name, z.name as zavod_name
    FROM incoming i
    LEFT JOIN cement_marks c ON i.cement_mark_id = c.id
    LEFT JOIN zavody z ON i.zavod_id = z.id
    ORDER BY i.date DESC
  `);
  res.json(data);
});

app.post('/api/incoming', async (req, res) => {
  const { date, machine_number, cement_mark_id, type, tonnage, price_per_ton, warehouse_received, zavod_id } = req.body;
  const total = tonnage * price_per_ton;
  
  const result = await run(`
    INSERT INTO incoming (date, machine_number, cement_mark_id, type, tonnage, price_per_ton, total_sum, warehouse_received, zavod_id)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `, [date, machine_number, cement_mark_id, type, tonnage, price_per_ton, total, warehouse_received ? 1 : 0, zavod_id]);
  
  // Обновляем остаток склада
  if (warehouse_received) {
    await updateWarehouseBalance(cement_mark_id, type, tonnage);
  }
  
  res.json(result);
});

// Остатки склада
app.get('/api/warehouse-balance', async (req, res) => {
  const data = await all(`
    SELECT w.*, c.name as cement_mark_name
    FROM warehouse_balance w
    LEFT JOIN cement_marks c ON w.cement_mark_id = c.id
    WHERE w.tonnage > 0
  `);
  res.json(data);
});

async function updateWarehouseBalance(cement_mark_id, type, tonnage) {
  const existing = await get(
    'SELECT * FROM warehouse_balance WHERE cement_mark_id = ? AND type = ?',
    [cement_mark_id, type]
  );
  
  if (existing) {
    await run(
      'UPDATE warehouse_balance SET tonnage = tonnage + ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [tonnage, existing.id]
    );
  } else {
    await run(
      'INSERT INTO warehouse_balance (cement_mark_id, type, tonnage) VALUES (?, ?, ?)',
      [cement_mark_id, type, tonnage]
    );
  }
}

// Продажи
app.get('/api/sales', async (req, res) => {
  const data = await all(`
    SELECT s.*, c.name as client_name, cm.name as cement_mark_name
    FROM sales s
    LEFT JOIN clients c ON s.client_id = c.id
    LEFT JOIN cement_marks cm ON s.cement_mark_id = cm.id
    ORDER BY s.date DESC
  `);
  res.json(data);
});

app.post('/api/sales', async (req, res) => {
  const { date, client_id, cement_mark_id, type, tonnage, price_per_ton, source, ticket_id, has_logistics, machine_number, machine_own, logistics_price_per_ton } = req.body;
  const total = tonnage * price_per_ton;
  const logistics_total = has_logistics ? tonnage * logistics_price_per_ton : 0;
  
  const result = await run(`
    INSERT INTO sales (date, client_id, cement_mark_id, type, tonnage, price_per_ton, total_sum, source, ticket_id, has_logistics, machine_number, machine_own, logistics_price_per_ton, logistics_total)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `, [date, client_id, cement_mark_id, type, tonnage, price_per_ton, total, source, ticket_id || null, has_logistics ? 1 : 0, machine_number, machine_own ? 1 : 0, logistics_price_per_ton || 0, logistics_total]);
  
  // Обновляем остатки
  if (source === 'warehouse') {
    await run('UPDATE warehouse_balance SET tonnage = tonnage - ? WHERE cement_mark_id = ? AND type = ?',
      [tonnage, cement_mark_id, type]);
  } else if (source === 'ticket' && ticket_id) {
    await run('UPDATE tickets SET remaining_tonnage = remaining_tonnage - ?, remaining_sum = remaining_sum - ? WHERE id = ?',
      [tonnage, total, ticket_id]);
  }
  
  res.json(result);
});

// Логистика
app.get('/api/logistics', async (req, res) => {
  const data = await all('SELECT l.*, c.name as client_name FROM logistics l LEFT JOIN clients c ON l.client_id = c.id ORDER BY l.date DESC');
  res.json(data);
});

app.post('/api/logistics', async (req, res) => {
  const { date, machine_number, machine_own, tonnage, price_per_ton, client_id } = req.body;
  const total = tonnage * price_per_ton;
  
  const result = await run(`
    INSERT INTO logistics (date, machine_number, machine_own, tonnage, price_per_ton, total_sum, client_id)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `, [date, machine_number, machine_own ? 1 : 0, tonnage, price_per_ton, total, client_id]);
  
  res.json(result);
});

// Касса - Приход
app.get('/api/cash-income', async (req, res) => {
  const data = await all(`
    SELECT c.*, cl.name as client_name
    FROM cash_income c
    LEFT JOIN clients cl ON c.client_id = cl.id
    ORDER BY c.date DESC
  `);
  res.json(data);
});

app.post('/api/cash-income', async (req, res) => {
  const { date, category, client_id, amount, currency, usd_rate, payment_type, comment } = req.body;
  
  const result = await run(`
    INSERT INTO cash_income (date, category, client_id, amount, currency, usd_rate, payment_type, comment)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `, [date, category, client_id || null, amount, currency, usd_rate || 1, payment_type, comment]);
  
  res.json(result);
});

// Касса - Расход
app.get('/api/cash-expense', async (req, res) => {
  const data = await all('SELECT * FROM cash_expense ORDER BY date DESC');
  res.json(data);
});

app.post('/api/cash-expense', async (req, res) => {
  const { date, category, machine_number, expense_type, amount, currency, payment_type, comment } = req.body;
  
  const result = await run(`
    INSERT INTO cash_expense (date, category, machine_number, expense_type, amount, currency, payment_type, comment)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `, [date, category, machine_number || null, expense_type, amount, currency, payment_type, comment]);
  
  res.json(result);
});

// Отчеты
app.get('/api/report/summary', async (req, res) => {
  const totalSales = await get('SELECT SUM(total_sum) as total FROM sales');
  const totalIncome = await get('SELECT SUM(amount) as total FROM cash_income');
  const totalExpense = await get('SELECT SUM(amount) as total FROM cash_expense');
  
  const sales_by_zavod = await all(`
    SELECT 
      COALESCE(t.zavod_id, i.zavod_id) as zavod_id,
      z.name,
      COUNT(*) as sales_count,
      SUM(s.tonnage) as total_tonnage,
      SUM(s.total_sum) as total_sum
    FROM sales s
    LEFT JOIN tickets t ON s.ticket_id = t.id
    LEFT JOIN incoming i ON s.cement_mark_id = i.cement_mark_id
    LEFT JOIN zavody z ON COALESCE(t.zavod_id, i.zavod_id) = z.id
    GROUP BY COALESCE(t.zavod_id, i.zavod_id), z.name
  `);
  
  const top_clients = await all(`
    SELECT 
      c.id, c.name,
      COUNT(*) as sales_count,
      SUM(s.tonnage) as total_tonnage,
      SUM(s.total_sum) as total_sum
    FROM sales s
    LEFT JOIN clients c ON s.client_id = c.id
    GROUP BY c.id, c.name
    ORDER BY total_sum DESC
    LIMIT 10
  `);
  
  res.json({
    totalSales: totalSales.total || 0,
    totalIncome: totalIncome.total || 0,
    totalExpense: totalExpense.total || 0,
    profit: (totalIncome.total || 0) - (totalExpense.total || 0),
    sales_by_zavod,
    top_clients
  });
});

// Запуск сервера
app.listen(PORT, () => {
  console.log(`\n🚀 Сервер запущен на http://localhost:${PORT}\n`);
});
