import csv
rows = list(csv.DictReader(open(r"D:/Research/Non-Stationarity-KG/03-writeup/prior-art/wos_corpus.csv", encoding="utf-8-sig")))
for pat in ["Khan", "Shen", "Tague", "Garcia", "Vormoor", "Calvin"]:
    print("===", pat)
    n = 0
    for r in rows:
        t = r["title"]
        if pat.lower() in t.lower() and n < 6:
            print(f"  ({r['year']}) {t[:90]} - {r['journal'][:30]}")
            n += 1
