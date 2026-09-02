# RdpV — Remote Desktop View-Only

> Lihat layar PC dari mana saja — **hanya melihat**, tanpa kontrol mouse/keyboard,
> tanpa transfer file. Aman lewat enkripsi TLS + token rahasia.

![Status](https://img.shields.io/badge/status-stable-green)
![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-blue)
![License](https://img.shields.io/badge/license-MIT-orange)
![.NET](https://img.shields.io/badge/.NET-8.0-purple)

---

## Download

| Komponen | Ukuran | Link |
|----------|--------|------|
| **Host Setup** (GUI installer) | ~190 MB | [Download](https://github.com/Keyyz12/rdpv/releases/download/v1.0/RdpV.Host.Setup.exe) |
| **Controller Setup** | ~96 MB | [Download](https://github.com/Keyyz12/rdpv/releases/download/v1.0/RdpV.Controller.Setup.exe) |
| **Host Indicator** (tray icon) | ~154 MB | [Download](https://github.com/Keyyz12/rdpv/releases/download/v1.0/RdpV.HostIndicator.exe) |
| **Relay Server** (untuk operator) | ~78 MB | [Download](https://github.com/Keyyz12/rdpv/releases/download/v1.0/RdpV.RelayServer.exe) |
| **Install Relay Script** | <1 MB | [Download](https://github.com/Keyyz12/rdpv/releases/download/v1.0/install-relay-service.ps1) |

Website download: **https://keyyz12.github.io/rdpv/**

---

## Arsitektur

```
┌────────────┐        TLS + frames        ┌─────────┐        TLS + frames        ┌────────────┐
│    Host    │ ◄─────────────────────────► │  Relay  │ ◄─────────────────────────► │ Controller │
│ (PC Klien) │       view-only            │ Server  │       view-only            │ (PC Teknisi)│
└────────────┘                            └─────────┘                            └────────────┘
       │                                                                 │
       └── Host Indicator (tray: hijau saat ada penonton)                └── Fullscreen mode
                                                                           (excl. dari capture)
```

**Alur koneksi:**
1. **Host** register ke relay dengan Device ID + token (hashed SHA-256)
2. **Controller** masukkan kode Device ID + token → relay verifikasi → paired
3. Frames dikirim via TLS, view-only — tidak ada kontrol mouse/keyboard

---

## Cara Pakai

### Skenario 1 — Pakai relay yang sudah ada

1. **Di PC yang layarnya mau dilihat (Host):**
   - Jalankan `RdpV.Host.Setup.exe` (klik kanan → Run as Administrator)
   - Isi **Relay host**, **Port**, dan **Relay CA** (file `.crt` dari penyedia relay)
   - Klik **Pasang Sekarang**
   - Catat **Device ID** dan **Auth Token** yang tampil → **klik Salin**

2. **Di PC penonton (Controller):**
   - Jalankan `RdpV.Controller.Setup.exe`
   - Buka **RdpV Controller**
   - Isi: Relay host, Port, Device ID, Auth Token, pilih file Trusted CA
   - Klik **Connect** → layar Host tampil

3. **Selesai melihat?** Klik **Disconnect**. Host otomatis idle.

### Skenario 2 — Pasang relay sendiri

```powershell
# Install relay sebagai Windows service (auto-start)
powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Port 8443

# Hapus relay
powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Uninstall
```

Relay otomatis:
- Publish + install sebagai service `RdpV.Relay`
- Buka port di Windows Firewall
- Buat sertifikat self-signed → bagikan `relay-ca.crt` ke klien

---

## Fitur

- **View-only** — tidak ada kontrol mouse/keyboard, tidak ada transfer file
- **TLS end-to-end** — semua komunikasi terenkripsi
- **Token rahasia** — akses hanya dengan Device ID + Auth Token (hashed, tidak pernah disimpan plain)
- **Host Indicator** — tray icon hijau saat ada penonton, normal saat idle
- **Resolution scaling** — pilih resolusi streaming sesuai kebutuhan
- **Fullscreen** — mode layar penuh, otomatis mengecualikan jendela Controller dari capture
- **Auto-start** — Host & Relay jalan sebagai Windows service, otomatis saat boot
- **Self-extracting installer** — satu file .exe, tidak perlu dependensi tambahan

---

## Persyaratan Sistem

- Windows 10 / 11 (x64)
- Tidak perlu .NET Runtime (sudah self-contained)

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Tidak bisa connect | Pastikan relay host/port/CA benar, relay online, port terbuka |
| Layar dalam layar (feedback loop) | Host & Controller di PC sama → pakai mode Fullscreen |
| Sempat connect lalu putus | Cek `sc query RdpV.Host` masih running |
| Resolusi tidak sesuai | Host hanya kirim resolusi native monitor |

---

## Bagi Operator Relay

Relay server harus selalu online dan bisa diakses dari internet. Opsi:
- **IP publik** + port forward
- **VPS** (minimal 1 core, 512 MB RAM)
- **Tailscale / Cloudflare Tunnel** untuk akses tanpa port forward

### Jalankan relay dari source

```bash
# Publish
dotnet publish src/RelayServer -c Release -r win-x64 --self-contained

# Jalankan (console)
src/RelayServer/bin/Release/net8.0-windows/win-x64/publish/RdpV.RelayServer.exe 8443

# Jalankan sebagai service
src/RelayServer/bin/Release/net8.0-windows/win-x64/publish/RdpV.RelayServer.exe --service 8443
```

### Sertifikat custom

```powershell
.\RdpV.RelayServer.exe 8443 --cert C:\certs\relay.pfx --certpass "rahasia"
```

---

## Lisensi

MIT License — bebas dipakai, dimodifikasi, dan didistribusikan.

---

## Support

- Issue: [GitHub Issues](https://github.com/Keyyz12/rdpv/issues)
- Panduan lengkap: [PANDUAN.md](https://keyyz12.github.io/rdpv/PANDUAN.md)
