-- 冷记忆建库脚本 → .agents/history/memory.db
-- 宿主在首次运行时执行一次。node:sqlite（Node >= 24 内置），零外部依赖。
--
-- ⚠️ FTS5 外部内容模式（content=）不会自动同步。必须建下面的触发器，
--    否则索引永远是空的 —— 实测：只建表不建触发器时，插入数据后 MATCH 命中 0 条。

PRAGMA journal_mode = WAL;

-- 原始历史（主流程每轮同步写，不缓冲不批量）
CREATE TABLE IF NOT EXISTS history (
  id         INTEGER PRIMARY KEY,
  workspace  TEXT NOT NULL,        -- 冗余校验：库随工作空间走，正常恒为同一个值
  session_id TEXT NOT NULL,
  turn_index INTEGER NOT NULL,
  role       TEXT NOT NULL,
  content    TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- 摘要（高层快照，对应 OpenClaw 的每日日志）
CREATE TABLE IF NOT EXISTS summary (
  id         INTEGER PRIMARY KEY,
  workspace  TEXT NOT NULL,        -- 同上，冗余校验
  scope      TEXT NOT NULL,        -- daily | task | session
  scope_key  TEXT NOT NULL,        -- daily: YYYY-MM-DD；task: taskId；session: sessionId
  digest     TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- 检索日志：晋级判定的数据源（同一主题累计命中 >= 3 次 → 提炼进温记忆）
CREATE TABLE IF NOT EXISTS search_log (
  id         INTEGER PRIMARY KEY,
  query      TEXT NOT NULL,        -- 原始查询串
  kind       TEXT NOT NULL,        -- history | summary
  hit_ids    TEXT NOT NULL,        -- 命中的 rowid 列表（JSON 数组）
  hit_count  INTEGER NOT NULL,
  created_at TEXT NOT NULL
);

-- 全文索引（中文用 trigram；查询串必须 >= 3 个字符，不足 3 字走 LIKE 回退）
CREATE VIRTUAL TABLE IF NOT EXISTS history_fts USING fts5(
  content, content='history', content_rowid='id', tokenize='trigram'
);
CREATE VIRTUAL TABLE IF NOT EXISTS summary_fts USING fts5(
  digest, content='summary', content_rowid='id', tokenize='trigram'
);

-- 同步触发器（6 个）
CREATE TRIGGER IF NOT EXISTS history_ai AFTER INSERT ON history BEGIN
  INSERT INTO history_fts(rowid, content) VALUES (new.id, new.content);
END;
CREATE TRIGGER IF NOT EXISTS history_ad AFTER DELETE ON history BEGIN
  INSERT INTO history_fts(history_fts, rowid, content) VALUES ('delete', old.id, old.content);
END;
CREATE TRIGGER IF NOT EXISTS history_au AFTER UPDATE ON history BEGIN
  INSERT INTO history_fts(history_fts, rowid, content) VALUES ('delete', old.id, old.content);
  INSERT INTO history_fts(rowid, content) VALUES (new.id, new.content);
END;

CREATE TRIGGER IF NOT EXISTS summary_ai AFTER INSERT ON summary BEGIN
  INSERT INTO summary_fts(rowid, digest) VALUES (new.id, new.digest);
END;
CREATE TRIGGER IF NOT EXISTS summary_ad AFTER DELETE ON summary BEGIN
  INSERT INTO summary_fts(summary_fts, rowid, digest) VALUES ('delete', old.id, old.digest);
END;
CREATE TRIGGER IF NOT EXISTS summary_au AFTER UPDATE ON summary BEGIN
  INSERT INTO summary_fts(summary_fts, rowid, digest) VALUES ('delete', old.id, old.digest);
  INSERT INTO summary_fts(rowid, digest) VALUES (new.id, new.digest);
END;

-- 若曾有数据先于触发器写入，补一次全量重建（正常首次建库不需要）：
-- INSERT INTO history_fts(history_fts) VALUES ('rebuild');
-- INSERT INTO summary_fts(summary_fts) VALUES ('rebuild');
