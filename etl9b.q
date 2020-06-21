etl9b.f:"ETL9B"
etl9b.b:"http://etlcdb.db.aist.go.jp/etlcdb/data/"
-1"[down]loading handwritten-kanji data set";
.ut.download[etl9b.b;;".zip";.ut.unzip] etl9b.f;
-1"loading etl9b ('binalized' dataset)";
etl9b.x:.ut.etl9b read1 `:ETL9B/ETL9B_1
-1"extracting the X matrix and y vector";
etl9b.h:0x24,/:"x"$0x21+0x01*til 83 / hiragana
/ etl9b.h:0x25,/:"x"$0x21+0x01*til 83 / katakana (missing)
etl9b.y:flip etl9b.x 1 2
etl9b.w:where etl9b.y in etl9b.h / find hiragana
etl9b.y:etl9b.h?etl9b.y etl9b.w
/ extract 0 1 from bytes
etl9b.X:"f"$flip (raze $[3.5>.z.K;-8#';::] 0b vs/:) each (1_etl9b.x 4) etl9b.w
