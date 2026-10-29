# BrenOS Safe Cleanup

Sigurno vizualno čišćenje nije uklanjanje Windowsa. Ovaj neobavezni modul postavlja nekoliko **HKCU** opcija za manje prijedloga, oglasa i Widgets ikone na programskoj traci. Opcionalno skriva uobičajene sistemske ikone na desktopu. Sve ostaje instalirano i dostupno preko Explorera.

### Prije primjene

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Safe-Cleanup.ps1 -DryRun
```

### Primjena (bez administratorskih prava)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Safe-Cleanup.ps1
```

Za skrivanje uobičajenih desktop ikona dodaj `-HideDesktopSystemIcons`.

### Povrat

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Restore-Cleanup.ps1
```

**Ne uklanja Windows aplikacije, ne blokira upozorenja o opasnosti, ne gasi Defender, Windows Update, SmartScreen ili UAC, ne mijenja grupne politike.** Radnja je pojedinačna i ne koristi destruktivne naredbe poput Remove-AppxPackage ili delete sistemskih datoteka. Neke postavke ovise o konkretnoj verziji Windowsa i možda neće imati vidljivi učinak.
