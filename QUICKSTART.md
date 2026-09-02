# RdpV — Quick Start Guide

> Panduan singkat untuk mulai menggunakan RdpV.
> Dibaca dalam 2 menit, langsung bisa dipakai.

---

## Sebelum Mulai

Pastikan kamu punya:

- **PC/Server relay** — selalu online, punya IP publik atau port forward
- **PC Host** — PC yang layarnya mau dilihat (bisa lebih dari 1)
- **PC Controller** — PC yang dipakai melihat layar Host

**File yang perlu di-download:**

Buka **https://keyyz12.github.io/rdpv/** dan download:

| File | Untuk apa |
|------|-----------|
| `install-relay-service.ps1` | Install relay otomatis |
| `RdpV.Host.Setup.exe` | Pasang di PC yang mau ditonton |
| `RdpV.Controller.Setup.exe` | Pasang di PC penonton |

---

## Alur Singkat

```
  PC Relay (server)          PC Host (klien)         PC Controller (anda)
  ─────────────────          ────────────────         ─────────────────────
  1. Install relay     →     2. Install Host    →     3. Install Controller
     Catat alamat + port        Catat ID + Token        Isi ID + Token
     Bagikan relay-ca.crt       Kirim ke penonton       Klik Connect
```

---

## Langkah 1 — Pasang Relay

> Pasang di PC/Server yang **selalu online** dan punya **IP publik**.

**Buka PowerShell sebagai Administrator**, lalu jalankan:

```powershell
powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Port 8443
```

**Yang perlu dicatat:**

| Item | Nilai | Keterangan |
|------|-------|------------|
| Alamat relay | `relay.contoh.com` atau IP publik | Alamat yang bisa diakses dari internet |
| Port | `8443` (default) | Port yang dibuka di firewall |
| File CA | `relay-ca.crt` | Kirim file ini ke semua klien |

**File CA located di:**
```
C:\ProgramData\RdpV\relay\.relay\relay-ca.crt
```

> Kirim file `relay-ca.crt` ke semua klien yang akan memasang Host dan Controller.

---

## Langkah 2 — Pasang Host

> Pasang di PC yang **layarnya mau dilihat** (PC klien).

1. **Klik kanan** `RdpV.Host.Setup.exe` → **Run as Administrator**
2. Isi form yang muncul:

| Field | Isi dengan |
|-------|-----------|
| Relay host | Alamat relay dari Langkah 1 |
| Relay port | Port dari Langkah 1 (default: 8443) |
| Relay CA | Klik **Pilih...** → cari file `relay-ca.crt` |

3. Klik **Pasang Sekarang**
4. Tunggu sampai selesai
5. **Catat Device ID dan Auth Token** yang tampil
   → Kirim ke penonton (yang pakai Controller)

---

## Langkah 3 — Pasang Controller

> Pasang di PC yang dipakai **melihat layar** Host.

1. Jalankan `RdpV.Controller.Setup.exe`
2. Buka aplikasi **RdpV Controller**
3. Isi form koneksi:

| Field | Isi dengan |
|-------|-----------|
| Relay host | Alamat relay dari Langkah 1 |
| Relay port | Port dari Langkah 1 |
| Device ID | Dari Host (Langkah 2) |
| Auth Token | Dari Host (Langkah 2) |
| Trusted CA | Klik **Trusted CA...** → pilih file `relay-ca.crt` |

4. Klik **Connect**
5. **Selesai!** Layar Host sekarang terlihat di layar Anda.

---

## Fitur Tambahan

| Fitur | Cara pakai |
|-------|-----------|
| **Fullscreen** | Tekan `Ctrl+Shift+F11` atau klik tombol Fullscreen |
| **Ubah resolusi** | Pilih di dropdown resolution (atas) |
| **Disconnect** | Klik tombol Disconnect di Controller |
| **Host Indicator** | Jalankan `RdpV.HostIndicator.exe` di PC Host → icon tray berubah hijau saat ada yang melihat |

---

## Masalah Umum

**Tidak bisa connect?**
- Pastikan relay host, port, dan CA benar
- Pastikan relay online (coba akses dari browser: `https://alamat-relay:8443`)
- Pastikan port firewall terbuka

**Layar dalam layar (feedback loop)?**
- Ini terjadi saat Host dan Controller di **PC yang sama**
- Solusi: pakai mode **Fullscreen** (`Ctrl+Shift+F11`)

**Sempat connect, lalu putus?**
- Cek relay masih online
- Cek Host service masih jalan: `sc query RdpV.Host`
- Coba reconnect dari Controller

---

## Ringkasan

```
Relay    →  Install  →  Catat alamat + port  →  Bagikan relay-ca.crt
Host     →  Install  →  Catat ID + Token     →  Kirim ke penonton
Controller → Install  →  Isi ID + Token      →  Connect → Selesai!
```
