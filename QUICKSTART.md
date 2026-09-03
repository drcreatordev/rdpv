# RdpV — Quick Start Guide

> Panduan singkat untuk **klien**. Cara memasang Host & Controller lalu menghubungkan keduanya.
> Dibaca dalam 2 menit.

---

## Sebelum Mulai

**Relay sudah disiapkan oleh penyedia/operator** — kamu tidak perlu mengurus server relay.

Yang kamu butuhkan:

| File | Dipasang di | Untuk apa |
|------|------------|-----------|
| `RdpV.Host.Setup.exe` | PC yang **layarnya mau dilihat** | Mengirim layar |
| `RdpV.Controller.Setup.exe` | PC yang dipakai **melihat** | Menampilkan layar Host |
| `relay-ca.crt` | Kedua PC | File kepercayaan (TLS) |

> Unduh semua dari: **https://drcreatordev.github.io/rdpv/**

---

## Info dari Operator (isi ini nanti)

Tanyakan / catat dari penyedia relay:

| Info | Contoh |
|------|--------|
| **Alamat relay** | `36.8.154.208` atau `relay.example.com` |
| **Port relay** | `8443` |
| **File CA** | `relay-ca.crt` (dikirim operator) |

Simpan 3 info ini — akan dipakai di Langkah 1 & 2.

---

## Alur

```
 PC Host                  PC Controller
 (layar dikirim)          (layar dilihat)
 ──────────────           ────────────────
 1. Install Host     →     2. Install Controller
    Catat ID + Token          Isi ID + Token
    Kirim ke penonton         Klik Connect
```

---

## Langkah 1 — Pasang di PC Host

> PC yang **layarnya ingin dilihat**.

1. **Klik kanan** `RdpV.Host.Setup.exe` → **Run as Administrator**
2. Isi form yang muncul:

| Field | Isi dengan |
|-------|-----------|
| Relay host | Alamat relay dari operator (mis. `36.8.154.208`) |
| Relay port | Port relay (mis. `8443`) |
| Relay CA | Klik **Pilih…** → cari file `relay-ca.crt` |

3. Klik **Pasang Sekarang**, tunggu sampai selesai
4. **Catat Device ID dan Auth Token** yang tampil
   → Kirim keduanya ke penonton (yang memakai Controller)

---

## Langkah 2 — Pasang di PC Controller

> PC yang dipakai **melihat layar** Host.

1. Jalankan `RdpV.Controller.Setup.exe`
2. Buka aplikasi **RdpV Controller**
3. Isi form koneksi:

| Field | Isi dengan |
|-------|-----------|
| Relay host | Alamat relay dari operator |
| Relay port | Port relay |
| Device ID | Dari Host (Langkah 1) |
| Auth Token | Dari Host (Langkah 1) |
| Trusted CA | Klik **Trusted CA…** → pilih file `relay-ca.crt` |

4. Klik **Connect**
5. **Selesai!** Layar Host terlihat di layar Anda.

---

## Fitur

| Fitur | Cara pakai |
|-------|-----------|
| **Fullscreen** | `Ctrl+Shift+F11` atau tombol Fullscreen |
| **Ubah resolusi** | Dropdown resolution di atas |
| **Disconnect** | Tombol Disconnect di Controller |
| **Indikator Host** | Di PC Host, tray icon berubah hijau saat ada yang melihat |

---

## Masalah Umum

**Tidak bisa connect?**
- Cek alamat relay, port, dan file CA sudah benar
- Cek Device ID dan Auth Token sudah benar
- Cek relay online (operator)

**Layar dalam layar (feedback loop)?**
- Terjadi saat Host & Controller di **PC yang sama**
- Solusi: pakai **Fullscreen** (`Ctrl+Shift+F11`)

**Sempat connect lalu putus?**
- Cek internet kedua PC
- Cek relay online (operator)
- Klik Connect lagi dari Controller
