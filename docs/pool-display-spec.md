# Zwembadscherm: implementatiespecificatie

Scherm: `hs_coaching_screen` (web, kiosk), resolutie **624×416**.
Logica en modellen: `hs_coaching_core`.
Ontwerpbron: de canvasborden (zie `reference/`), uitgewerkt in het kruimelpad-voorstel. De boomweergave (B) is vervallen en wordt niet gebouwd.

Status: het ontwerp is goedgekeurd op structuur en layout. **De kleuren en lettertypes zijn voorlopig.** Ze moeten in een latere fase gealigneerd worden met het stijlbestand van de coaching app (zie §7). Bouw ze daarom van meet af aan als aanpasbare tokens, niet als losse hexwaarden in widgets.

---

## 1. Wat het scherm moet doen

Een speler in het zwembad moet in één oogopslag zien:

1. **Waar zit ik?** Positie in de nesting Set > Subset > Oefening > Herhaling.
2. **Wat is al gedaan en wat komt nog?** Per niveau.
3. **Wat moet ik nu doen?** De lijnen van de huidige oefening, met de lopende timer.
4. **Wat komt daarna?** Altijd zichtbaar, ook bij het terugspringen naar het begin van een set of subset.

## 2. Domeinregels (door de eigenaar bevestigd)

- **Codes in een lijn.** `AB` = armen en benen, `B` = enkel benen, `Bov` / `Ond` = boven- / onderwater (`HaBo` komt ook voor, toon zoals in de data, in hoofdletters), `0%` = inspanningsniveau, `–` = niet opgegeven door de coach.
- **Eén timer per oefening.** De werktijd geldt voor **alle lijnen samen**. De speler verdeelt de tijd zelf. Er is dus **geen voortgang of "huidige lijn" binnen een oefening**. Toon alle lijnen tegelijk, gelijkwaardig.
- **Werktijd en rust per herhaling.** `werk(n) = basiswerk + (n − 1) × Δ`. De **rust blijft constant**. Δ is dus een verschil in werktijd per herhaling (`d−` korter, `d+` langer).
- **Group split.** Elke groep (bijvoorbeeld Hard en Easy) heeft een **eigen timer**, **eigen werk/rust** en **eigen lijnen** (twee per groep in het ontwerp). Beide groepen zijn tegelijk zichtbaar.
- **Voorbeeldstructuur** (uit de backend-screenshot):
  - Warmup, 1×: vier lijnen (10× 25 m AB Bov, 10× 25 m B Bov, 10× 25 m AB HaBo, 5× 25 m B Ond), werk 10 s, rust 10 s.
  - Set, 2×:
    - Group split, 1×: Hard (werk 15, rust 10) en Easy (werk 10, rust 10).
    - Subset, 2×:
      - Oefening 1 `d−`, 2×: twee lijnen van 1× 25 m, werk 10, rust 10, Δ −5 s.
      - Oefening 2 `d+`, 2×: twee lijnen van 1× 25 m, werk 10, rust 10, Δ +5 s.

## 3. Stappenmodel (in `hs_coaching_core`, puur Dart, geen Flutter)

De bestaande (recursieve `TrainingGroup`-)structuur wordt **afgevlakt tot een lineaire lijst stappen**. Eén stap is **één herhaling van één oefening**. Het scherm toont altijd stap `n` (nu) en stap `n+1` (daarna). Pas de namen hieronder aan op de bestaande types, het gaat om het gedrag.

Elke stap draagt een pad met per niveau `(index, aantal)`:

- `set`, `subset`, `oefening` (positie binnen de ouder) en `herhaling`. Niveaus die niet van toepassing zijn (bijvoorbeeld de warmup of de group split) zijn `null`.
- de lijnen van de oefening (of per groep voor een group split), met werk, rust en Δ.
- het totaal aantal banen van de stap (som van `reps` over de lijnen; bij een group split per groep).

### 3.1 Overgang (`n → n+1`)

Vergelijk de paden van `n` en `n+1`. Het **hoogste niveau dat verandert** bepaalt de overgang:

| Hoogste wisselend niveau | Overgang | Weergave |
|---|---|---|
| geen set → set | `enterSet` | pill "Nieuwe set ›" |
| geen subset → subset | `enterSubset` | pill "Nieuwe subset ›" |
| set 1 → 2 (zelfde blok opnieuw) | `repeatSet` | pill "Set opnieuw ↻" |
| subset 1 → 2 | `repeatSubset` | pill "Subset opnieuw ↻" |
| oefening wisselt | `newExercise` | pill "Nieuwe oefening ›" |
| alleen herhaling wisselt | `nextRepetition` | pill "Volgende herhaling ›" (nog niet ontworpen, volg de stijl van de andere pills) |
| na de laatste stap | `done` | geen Daarna-kaart, Klaar-scherm (nog niet ontworpen) |

Bij elke overgang toont de Daarna-kaart de **eerste stap van de nieuwe ronde** (dus bij `repeatSet` de group split van set 2).

### 3.2 Bolletjes per niveau (kruimelpad)

Per niveau staan `aantal` bolletjes verbonden door een lijntje. Toestanden:

- **gedaan**: gevuld, gedempt, met vinkje, lijntje ervoor gedempt.
- **nu**: groter, gevuld, met ring.
- **straks**: hol, in de "straks"-kleur. Alleen op het **hoogste niveau dat wisselt**. Lagere niveaus resetten vanzelf en krijgen niets.
- **nog te komen**: hol, neutraal.

Bij `repeatSet` en `repeatSubset` komt er naast de bolletjes een ↻-icoon. Er staan **geen breuken** (1/2, 2/2) in de UI, de bolletjes zijn de enige telling.

Als er een niveau wisselt dat nu niet in het pad staat (warmup → set, group split → subset), toon dan een **gestippelde spookchip** met dat niveau (bolletjes: eerste "straks", rest "nog te komen").

### 3.3 Herhalingstrack (in het timervak)

Een rij nodes, één per herhaling van de huidige oefening, verbonden door een lijntje. Onder elke node staat de werktijd van die herhaling (`werk(n)`). Toestanden zoals hierboven (gedaan, nu, nog te komen). Een oefening met één herhaling toont één node (zo blijft de plek op elk scherm gelijk).

### 3.4 Banenteller (subtiel, rechtsboven)

Tekst `gedaan / totaal banen` en de voortgangsbalk bovenaan, beide gebaseerd op **banen vóór het begin van de huidige stap**. Er is geen voortgang binnen een stap.

**Open punt:** bij een group split hebben groepen een verschillend aantal banen. In de referentieschermen is de Hard-route gebruikt (totaal 117). Zonder kennis van de groep van de speler zou Easy op 107 uitkomen. Beslis: groep kiezen, of de teller laten vallen.

### 3.5 Verwachte uitkomst voor de voorbeeldstructuur (19 stappen, nagerekend)

| # | Pad (set / sub / oef / herh) | Werk / rust | Overgang naar volgende |
|---|---|---|---|
| 1 | warmup | 10 / 10 | enterSet |
| 2 | set 1, group split | Hard 15/10, Easy 10/10 | enterSubset |
| 3 | 1 / 1 / 1 / 1 | 10 / 10 | nextRepetition |
| 4 | 1 / 1 / 1 / 2 | **5** / 10 | newExercise |
| 5 | 1 / 1 / 2 / 1 | 10 / 10 | nextRepetition |
| 6 | 1 / 1 / 2 / 2 | **15** / 10 | repeatSubset |
| 7 | 1 / 2 / 1 / 1 | 10 / 10 | nextRepetition |
| 8 | 1 / 2 / 1 / 2 | 5 / 10 | newExercise |
| 9 | 1 / 2 / 2 / 1 | 10 / 10 | nextRepetition |
| 10 | 1 / 2 / 2 / 2 | 15 / 10 | **repeatSet** |
| 11 | set 2, group split | Hard 15/10, Easy 10/10 | enterSubset |
| 12 | 2 / 1 / 1 / 1 | 10 / 10 | nextRepetition |
| 13 | 2 / 1 / 1 / 2 | 5 / 10 | newExercise |
| 14 | 2 / 1 / 2 / 1 | 10 / 10 | nextRepetition |
| 15 | 2 / 1 / 2 / 2 | 15 / 10 | repeatSubset |
| 16 | 2 / 2 / 1 / 1 | 10 / 10 | nextRepetition |
| 17 | 2 / 2 / 1 / 2 | 5 / 10 | newExercise |
| 18 | 2 / 2 / 2 / 1 | 10 / 10 | nextRepetition |
| 19 | 2 / 2 / 2 / 2 | 15 / 10 | done |

Banen vóór stap (Hard-route, group split = 20 + 5 = 25 banen, Easy-route 15 + 5 = 20): stap 1 → 0, stap 2 → 35, stap 4 → 62, stap 10 → 74, totaal 117 (Easy: 57, 69, totaal 107).

Referentiescript: `check_steps.py` (Python, in dit pakket) rekent bovenstaande na en mag als testorakel dienen.

## 4. Schermindeling (624×416)

Vaste zones, **op elk scherm op dezelfde plek**. Padding: boven 20, zijkanten 16, onder 14. Tussenruimte tussen zones 10.

| Zone | Hoogte | Inhoud |
|---|---|---|
| Voortgangsbalk | 6 (absoluut, boven) | vulling = banen vóór de stap / totaal |
| Banenlabel | absoluut, rechts 16, boven 12 | `62 / 117 banen`, 13 px, gedempt |
| Kruimelrij | 60 | chips links (SET › SUBSET › OEFENING), titel van de oefening rechts, 17 px |
| Midden | 196 | links timervak (226 breed), rechts lijnenvak (rest, ±352) met 14 ertussen |
| Daarna | 106 | dezelfde twee kolommen (226 / rest) |

### 4.1 Kruimelchip

Hoogte 60, padding 0 14, afrondingsstraal 10, rand 1.5 px. Label 12 px, 600, letterafstand .1em. Bolletjes 20 px, verbonden met een lijntje van 18×3. "Nu" heeft een ring (3 px tussenruimte, 3 px ring). Chevrons tussen de chips: 14 px.

### 4.2 Timervak (226×196, padding 12 14)

Verticaal drie delen met `space-between`: fase-pill (WERK of RUST), grote timer (Barlow Condensed 700, 80 px, regelhoogte .9), herhalingstrack (label 11 px, nodes 24 px, tijd 15 px of 17 px voor "nu").

### 4.3 Rij met specificatie (boven de lijnen)

Drie gelijke kolommen: **herhalingen** (links, bijvoorbeeld `2×`), **werk / rust van de huidige herhaling** (midden, bijvoorbeeld `5 / 10 s`) en **Δ** (rechts, bijvoorbeeld `Δ −5s`). Leeg als niet van toepassing (warmup: alleen het midden). Chip 21 px / 700, hoogte 28. In de Daarna-kaart dezelfde rij op 16 px, hoogte 24, met de tijden van de **eerste herhaling** van de volgende oefening.

### 4.4 Lijnrij: vaste vijf kolommen

`grid-template-columns: 0.9fr 1.3fr 0.9fr 0.7fr 1.1fr`, alles gecentreerd:

1. aantal (`20×`), 2. afstand (`25 m`), 3. techniek (`AB`/`B` als chip), 4. inspanning (`0%`, of een gedempte `–`), 5. omgeving (`BOV`/`OND`/`HABO` als chip).

Dezelfde verhoudingen op elk scherm. Maten per context:

| Context | Rijhoogte | Cijfers | Chips | Inspanning |
|---|---|---|---|---|
| 2 lijnen in het lijnenvak | 76 | 44 | 22 | 34 |
| 4 lijnen (warmup) | 36 | 28 | 17 | 24 |
| Group split, nu (per groep 2 lijnen) | 36 | 28 | 17 | 24 |
| Daarna, gewone oefening | 26 | 20 | 13 | 17 |
| Daarna, group split (twee kolommen) | 26 | 17 | 11.5 | 15 |

Rij: achtergrond verhoogd, rand 2 px (in Daarna geen rand).

### 4.5 Group split, nu-scherm

Midden: links **twee timervakken** (elk 226×94: groepspill, werk/rust, WERK-pill, timer 50 px), rechts **twee lijnenblokken** van 94 hoog met de twee lijnen van die groep, uitgelijnd met de timers. Geen herhalingstrack en geen specificatierij.

### 4.6 Daarna-kaart

Gedempt: neutrale rand 1.5 px, donkerdere achtergrond. Links (226): label `DAARNA` in de straks-kleur, pill (alleen omlijnd, niet gevuld) met de overgang, en de naam van de volgende oefening. Rechts: specificatierij + lijnen, of bij een group split twee kolommen (groepspill + `werk / rust`, twee lijnen). Bij een group split staat de herhaling van de set als chip `set 2×` naast de naam links.

## 5. Schermen in het ontwerp

| Bestand in `reference/` | Toestand |
|---|---|
| `Warmup.dc.html` | stap 1 (warmup, vier lijnen samen, Daarna = group split) |
| `GroupSplit.dc.html` | stap 2 (twee timers, Daarna = subset) |
| `Main.dc.html` | stap 4 (oefening 1 d−, herhaling 2, WERK) |
| `LusEindeA.dc.html` | stap 10 (oefening 2 d+, herhaling 2, RUST, Daarna = set opnieuw ↻) |
| `Logica.dc.html` | tabel en regels (zelfde inhoud als §3) |

De `.dc.html`-bestanden zijn statische mockups met inline CSS. Lees er exacte maten en kleuren uit, maar neem de HTML niet over.

## 6. Nog niet ontworpen

- Klaar-scherm, en eventueel een startscherm vóór de warmup.
- `nextRepetition` als Daarna-toestand (pill "Volgende herhaling").
- Wat er in de Daarna-zone gebeurt tijdens de rustfase (nu blijft ze dezelfde grootte).
- Meer dan twee herhalingen (de track past ±4 nodes in 198 px: schalen of afkappen), meer dan vier lijnen, meer dan twee groepen, lange titels (afkappen met ellipsis).
- Dieper genest dan Set > Subset > Oefening > Herhaling. Het recursieve `TrainingGroup`-model laat meer niveaus toe. Spreek af hoe het kruimelpad zich dan gedraagt.
- Werktijd onder nul of onder een minimum door een grote negatieve Δ (afspreken: klemmen op bijvoorbeeld 1 s).
- Gedrag aan het einde van de laatste rust.

## 7. Kleuren en typografie: tokens, later te aligneren

Maak één `PoolDisplayTheme` (bijvoorbeeld een `ThemeExtension`) met onderstaande **semantische** namen. Alle widgets lezen alleen uit dit thema. Het later aligneren met het stijlbestand van de coaching app is dan een wijziging op één plek.

| Token | Waarde nu | Betekenis |
|---|---|---|
| `background` | `#08161F` | schermachtergrond |
| `surface` | `#0F2531` | timervak, chips, kruimelchips |
| `surfaceRow` | `#12394A` | lijnrij |
| `rowBorder` | `#2A4B5C` | rand lijnrij, connectors |
| `daarnaSurface` / `daarnaBorder` / `daarnaRow` | `#0B1D28` / `#1F3C4C` / `#102B3A` | gedempte Daarna-kaart |
| `chipSurface` / `chipBorder` | `#163545` / `#3C6276` (`#5B8196` in grote rijen) | techniek- en specificatiechips |
| `textPrimary` / `textSecondary` / `textMuted` / `textFaint` | `#F4FAFC` / `#CFE0E8` / `#9DB6C2` / `#6F8C99` | tekst |
| `now` | `#FF9F43` | positie "nu" (bolletjes, track, voortgangsbalk) |
| `next` | `#B79BFF` | "straks" (volgende bolletje, spookchip, Daarna-label en -pill) |
| `work` (+ `onWork` `#06222B`) | `#3EE0D0` | werkfase |
| `rest` (+ `onRest` `#06182E`) | `#7CC4FF` | rustfase |
| `done` (+ vinkje `#DCEBF1`) | `#3A5F70` | gedaan bolletje en lijntje |
| `upcoming` | `#5B8196` | nog te komen (holle bolletjes) |
| `envAbove` / `envUnder` | `#1C4256` op `#CFE9F2`, `#274AA8` op wit (rand `#5B82E0`) | Bov (en HaBo) / Ond |
| `groupHard` / `groupEasy` | `#B3341F` / `#1F7A4D` (witte tekst) | groepspills (de groepsnamen en -kleuren komen uit de data, dit zijn alleen de voorbeeldkleuren) |

Typografie nu: **Barlow Condensed** (600/700) voor cijfers en lijnen, **Barlow** (500/600/700) voor labels. Bundel de fonts lokaal in `hs_coaching_screen` (kiosk, mogelijk zonder internet). Vervang bij het aligneren met het stijlbestand door de app-fonts, maar behoud de **groottes en de grid**.

Kleur mag niet de enige drager van betekenis zijn: "nu / straks / gedaan" verschillen ook in vorm (gevuld, groter met ring, hol, vinkje). Behoud dat bij het herkleuren.

## 8. Testplan

**`hs_coaching_core` (unit tests):**

1. Afvlakken van de voorbeeldstructuur geeft 19 stappen met de paden uit §3.5.
2. Overgangen precies zoals in de tabel (met name 4→5, 6→7, 10→11 en 19→klaar).
3. Werktijd per herhaling: oefening 1 d− geeft 10 en 5, oefening 2 d+ geeft 10 en 15. Rust blijft 10.
4. Banen vóór stap en totaal (Hard 117, Easy 107 volgens §3.4).
5. Randgevallen: oefening met één herhaling, structuur zonder set, set zonder subset, nul Δ, groep zonder lijnen.

**`hs_coaching_screen` (widget- en golden tests):**

1. Eén golden test per referentiescherm op **624×416** (stap 1, 2, 4, 10), vergeleken met de geëxporteerde PNG's van de borden. Gebruik een tolerantie voor lettertype-verschillen.
2. Widgettest: de vijf kolommen van een lijnrij staan in elk scherm op dezelfde relatieve positie.
3. Widgettest: bij `repeatSet` toont de Daarna-kaart de group split van de volgende set en krijgt de SET-chip ↻.

## 9. Voorgestelde volgorde

1. Verken `hs_coaching_core`, `hs_coaching_screen` en het huidige pool-display-onderdeel. Vat samen waar dit past en hoe het recursieve model eruitziet. **Stel een plan voor voordat je schrijft.**
2. Afvlakken, overgangen, werktijden en banen in core, met tests (§8).
3. `PoolDisplayTheme` met de tokens uit §7.
4. Widgets in deze volgorde: lijnrij, specificatierij, kruimelchip, herhalingstrack, timervak, Daarna-kaart, schermen. Dan de group split.
5. Golden tests en de open punten uit §6 oplossen of expliciet laten staan.
6. Aansluiten op de bestaande chronometer (gedeelde Firebase-tijd) zodat timers en stap-overgangen op elk scherm gelijk lopen.

---

## 10. Herwerking 2026-11-07 (vervangt delen van §3.2–§4.6)

Op vraag van de eigenaar, na de eerste versie:

- **Voortgangsbalk** in plaats van de kruimelrij: één balkje per oefening, een kader per set/subset, **niet uitgerold** (een subset 3× staat er één keer). Onder elk element `x/y`: 0 = nog niet begonnen, de lopende ronde, `y` = af; de tellers binnen een groep resetten bij een nieuwe ronde. Breedte volgens het aantal banen (oefening: banen van al haar herhalingen; groep: som van de kinderen), met een minimumbreedte. Core: `buildProgressBar` in `lib/training/display/display_progress.dart`.
- **Weg:** kruimelpad (de widget `BreadcrumbRow` blijft in de code, ongebruikt), titels, banenteller en de dunne balk bovenaan, de specificatierij, de herhalingstrack, overgangspills.
- **Timervak:** fase-pill, timer, en onderaan de herhaling als `x/y` (ook `1/1`) met daarnaast `W: 00:05 (−5s)` (werk van déze herhaling, delta enkel als die er is) en `R: 00:10`. Group split: per groep een vak met groepspill, `x/y`, fase-pill, timer en W/R.
- **Lijnen:** vaste rijhoogte alsof er 5 lijnen zijn; minder lijnen staan bovenaan, pas vanaf 6 lijnen worden de rijen kleiner.
- **Onderste vak:** één breed vak met de **volgende oefening** (de herhalingen van de huidige overgeslagen, `TrainingDisplayPosition.nextExercise`) in haar eerste herhaling: `N×`, W/R en de lijnen (5 plaatsen, niet groter bij minder lijnen). Oranje rand (`now`) bij de laatste herhaling van de huidige oefening. Na de laatste oefening: `END`. Group split: twee helften.
