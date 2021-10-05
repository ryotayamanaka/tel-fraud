
# Artificial bias

DELETE FROM transaction WHERE acc_id_dst >= 0 AND acc_id_dst <= 9;
COMMIT;

UPDATE account SET is_suspect = 1 WHERE acc_id BETWEEN 0 AND 9;
COMMIT;

UPDATE account SET is_victim = 1 WHERE acc_id IN (66, 64, 74);
COMMIT;

INSERT INTO transaction VALUES　(12, 5, 10001, null, null);
INSERT INTO transaction VALUES　(12, 6, 10002, null, null);
INSERT INTO transaction VALUES　(12, 0, 10003, null, null);
COMMIT;

# SQL - in/out degree を見るだけでも大変（本来は LEFT OUTER が必要）

SELECT a.acc_id, a.tel_number, t.cnt
FROM account a
   , ( SELECT t.acc_id_src, COUNT(*) AS cnt
       FROM transaction t
       GROUP BY t.acc_id_src )t
WHERE a.acc_id = t.acc_id_src
ORDER BY t.cnt
;

SELECT a.acc_id, a.tel_number, t.cnt
FROM account a
   , ( SELECT t.acc_id_dst, COUNT(*) AS cnt
       FROM transaction t
       GROUP BY t.acc_id_dst )t
WHERE a.acc_id = t.acc_id_dst
ORDER BY t.cnt
;

ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

# デモ開始 (telfraud_call グラフ)

SELECT *
FROM MATCH ()-[e]->()
LIMIT 100

被害者に色をつける

# まずは所有者情報も

SELECT *
FROM MATCH ()-[e:OWNS]->()
LIMIT 100

# 被害者1

SELECT *
FROM MATCH (a1)<-[c1]-(a)
WHERE a1.tel_number = '070-6230-2482'

# 被害者2

SELECT *
FROM MATCH (a1)<-[c1]-(a)
WHERE a1.tel_number = '070-6111-6340'

# 共通の手口

SELECT *
FROM MATCH ( (a1)<-[c1]-(a), (a2)<-[c2]-(a) )
WHERE a1.tel_number = '070-6230-2482'
  AND a2.tel_number = '070-6111-6340'

# 誰からもかかってきていない (telfraud_call グラフに切り替え)

SELECT a.acc_id, a.tel_number, a.in_degree, a.out_degree
FROM MATCH (a)
WHERE a.in_degree < 5

(再度実行)

SELECT *
FROM MATCH ( (a1)<-[c1]-(a), (a2)<-[c2]-(a) )
WHERE a1.tel_number = '070-6230-2482'
  AND a2.tel_number = '070-6111-6340'

(ハイライト変更)

(ダブルクリック)

# 全体を見る

SELECT *
FROM MATCH (a)-[c1]->(a1)
WHERE a.in_degree < 5

# あやしい番号のうち連絡先を共有している

SELECT a1.tel_number AS a1, a2.tel_number AS a2, COUNT(*) AS cnt
FROM MATCH (a1)-[c1]->(a)<-[c2]-(a2)
WHERE a1.in_degree < 5 AND a2.in_degree < 5 AND ALL_DIFFERENT(a1, a2)
GROUP BY a1.tel_number, a2.tel_number
ORDER BY cnt DESC

# みてみる

SELECT *
FROM MATCH (a)-[c1]-(a1)
WHERE a.tel_number IN ('070-8946-4213', '080-6874-9484', '080-7890-1495')

# こいつは？

SELECT *
FROM MATCH (a)<-[c1]-(a1)
WHERE a.tel_number IN ('070-8946-4213', '080-6874-9484', '080-7890-1495')

（グラフを切り替えれば所有者も見える）

# おまけ）時間などつけていこうとするとクエリも大変になっていく

SELECT *
FROM MATCH (a1)-[c1]->(a)<-[c2]-(a2)
WHERE a1.in_degree = 0 AND a1.in_degree = 0
  AND c1.datetime >= TIMESTAMP '2020-10-01 00:00:00' AND c1.datetime <= TIMESTAMP '2020-12-31 00:00:00'
  AND c2.datetime >= TIMESTAMP '2020-10-01 00:00:00' AND c2.datetime <= TIMESTAMP '2020-12-31 00:00:00'
