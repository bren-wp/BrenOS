# Što BrenOS može sigurno promijeniti

| Komponenta | Trenutačni status | Sigurnost i vraćanje |
| --- | --- | --- |
| 4K, Full HD, QHD, ultrawide desktop pozadine | Funkcionalno | Izvorna pozadina se snima |
| Tamni način aplikacija i zadataka | Funkcionalno | Spremljene registry vrijednosti |
| BrenOS Control Center | Funkcionalna WPF aplikacija | Desktop prečac može se ukloniti |
| 50 vlastitih ikona, SVG/PNG/ICO | Izrađeno u build paketu | Ne zamjenjuje shell32/imageres |
| 15 pokazivača, CUR | Pripremljeni kao resurs | Ručna/opcionalna primjena |
| 5 originalnih WAV zvukova | Pripremljeni kao resurs | Windows zvučna shema se ne mijenja |
| Skrivanje preporuka, sadržaja i Widgets gumba | Opcionalni Safe Cleanup | Zapisuje originalne postavke |
| BrenOS prečaci s ikonama | Opcionalno | Ne dira izvorne prečace |
| Start i Explorer 1:1 kompletno redizajnirani | Koncept / zasebni budući shell projekt | Nativni Windows nije zamijenjen |
| Settings, UAC, secure desktop, boot logo i dijalozi | Ne mijenja se | Očuvan integritet Windowsa |
| Windows Security, Defender, Update, servisi | Ne mijenja se | Očuvana zaštita |

**Ne briši Windows izvorne sistemske ikone, resurse, DLL datoteke niti zaštićene komponente.** Udaljavanje ugrađenih grafika nije sigurna kozmetička optimizacija, nego neodrživo patchanje Windowsa.

## Prilagodba veličinama zaslona

BrenOS grafika izvodi se u veličinama 1920×1080, 2560×1440, 3840×2160 i 3440×1440. Windows bira prikaz s Fill/crop; prilagodba položaja orbitalnog motiva ovisi o omjeru zaslona. WPF koristi logičke device-independent jedinice i Windows DPI skaliranje. Provjeriti u virtualnom računalu s 100, 125, 150, 175, 200 i 250 % te s više monitora (posebno 1366×768 i portrait). Na svim DPI razinama ne mogu biti identični fizički pikseli, ali sadržaj mora biti čitljiv, bez preklapanja.
