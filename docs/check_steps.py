"""Rekent de stappenlijst, overgangen, werktijden en banentelling na voor de pool display spec."""

# Structuur zoals in de backend-screenshot
# lines: (reps, techniek, omgeving)
WARMUP = dict(name="Warmup", work=10, rest=10, delta=0,
              lines=[(10, "AB"), (10, "B"), (10, "AB"), (5, "B")])
GS = dict(name="Group split",
          groups={"Hard": dict(work=15, rest=10, lines=[(20, "AB"), (5, "B")]),
                  "Easy": dict(work=10, rest=10, lines=[(15, "AB"), (5, "B")])})
EX1 = dict(name="1 d-", reps=2, work=10, rest=10, delta=-5, lines=[(1, "AB"), (1, "AB")])
EX2 = dict(name="2 d+", reps=2, work=10, rest=10, delta=+5, lines=[(1, "AB"), (1, "AB")])

steps = []
steps.append(dict(kind="warmup", set=None, sub=None, ex=None, rep=None))
for s in (1, 2):
    steps.append(dict(kind="gs", set=s, sub=None, ex=None, rep=None))
    for sub in (1, 2):
        for ex, e in ((1, EX1), (2, EX2)):
            for rep in (1, 2):
                work = e["work"] + (rep - 1) * e["delta"]
                steps.append(dict(kind="ex", set=s, sub=sub, ex=ex, rep=rep, work=work, rest=e["rest"]))


def banen(step, group="Hard"):
    if step["kind"] == "warmup":
        return sum(r for r, _ in WARMUP["lines"])
    if step["kind"] == "gs":
        return sum(r for r, _ in GS["groups"][group]["lines"])
    e = EX1 if step["ex"] == 1 else EX2
    return sum(r for r, _ in e["lines"])


def key(s, level):
    return (s["set"], s["sub"], s["ex"], s["rep"])[:level]


def transition(a, b):
    if b is None:
        return "klaar"
    # hoogste niveau dat verandert: 0 set, 1 sub, 2 ex, 3 rep
    ka, kb = (a["set"], a["sub"], a["ex"], a["rep"]), (b["set"], b["sub"], b["ex"], b["rep"])
    for lvl in range(4):
        if ka[lvl] != kb[lvl]:
            if ka[lvl] is None:
                return ["nieuwe set", "nieuwe subset", "nieuwe oefening", "nieuwe herhaling"][lvl]
            if kb[lvl] is None:
                return "verlaat"
            if lvl == 0:
                return "set opnieuw"
            if lvl == 1:
                return "subset opnieuw"
            if lvl == 2:
                return "nieuwe oefening"
            return "volgende herhaling"
    return "zelfde"


print("aantal stappen:", len(steps))
for i, s in enumerate(steps, 1):
    nxt = steps[i] if i < len(steps) else None
    print(i, s, "->", transition(s, nxt))

for group in ("Hard", "Easy"):
    totaal = sum(banen(s, group) for s in steps)
    voor = []
    acc = 0
    for s in steps:
        voor.append(acc)
        acc += banen(s, group)
    print(group, "totaal", totaal, "voor stap 2/4/10:", voor[1], voor[3], voor[9], "voor stap 1:", voor[0])
