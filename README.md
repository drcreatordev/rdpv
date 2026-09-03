# RdpV — Remote Desktop View-Only

> Lihat layar PC dari mana saja — **hanya melihat**, tanpa kontrol mouse/keyboard,
> tanpa transfer file. Aman lewat enkripsi TLS + token rahasia.

![Status](https://img.shields.io/badge/status-stable-green)
![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-blue)
![.NET](https://img.shields.io/badge/.NET-8.0-purple)
![License](https://img.shields.io/badge/license-MIT-orange)

---

## 📥 Download

Buka website download: **https://drcreatordev.github.io/rdpv/**

| Komponen | Ukuran | Link |
|----------|--------|------|
| 🖥️ **Host Setup** (GUI installer) | ~190 MB | [Download](https://github.com/drcreatordev/rdpv/releases/download/v1.0/RdpV.Host.Setup.exe) |
| 🎬 **Controller Setup** | ~96 MB | [Download](https://github.com/drcreatordev/rdpv/releases/download/v1.0/RdpV.Controller.Setup.exe) |
| 🩺 **Host Indicator** (tray icon) | ~154 MB | [Download](https://github.com/drcreatordev/rdpv/releases/download/v1.0/RdpV.HostIndicator.exe) |
| 🛰️ **Relay Server** (untuk operator) | ~78 MB | [Download](https://github.com/drcreatordev/rdpv/releases/download/v1.0/RdpV.RelayServer.exe) |
| ⚙️ **Install Relay Script** | <1 MB | [Download](https://github.com/drcreatordev/rdpv/releases/download/v1.0/install-relay-service.ps1) |

> 💡 **Panduan cepat:** [QUICKSTART.md](https://drcreatordev.github.io/rdpv/QUICKSTART.md) — 3 langkah simpel untuk klien.
> 📖 **Panduan lengkap:** [PANDUAN.md](https://drcreatordev.github.io/rdpv/PANDUAN.md)

---

## 🧭 Tentang

**RdpV** adalah aplikasi **remote desktop view-only** — kamu bisa **melihat layar** PC lain
dari mana saja, **tanpa** kontrol mouse/keyboard dan **tanpa** transfer file. Dirancang
khusus untuk kebutuhan *monitoring* / *tech support* yang aman dan ringan.

### Kenapa RdpV?

- ✅ **Hanya melihat** — tidak bisa mengontrol, cocok untuk monitoring
- ✅ **Enkripsi TLS** — semua koneksi aman
- ✅ **Token rahasia** — akses terkontrol, tidak ada backdoor
- ✅ **Self-contained** — satu file .exe, tanpa perlu install .NET

---

## 🏗️ Arsitektur

```
┌────────────┐        TLS (frames)         ┌─────────┐        TLS (frames)         ┌────────────┐
│    Host    │ ◄─────────────────────────► │  Relay  │ ◄─────────────────────────► │ Controller │
│ (PC Klien) │         view-only           │ Server  │         view-only           │ (PC Penonton)│
└────────────┘                             └─────────┘                             └────────────┘
       │                                                                  │
       └── Host Indicator (tray: hijau saat ada penonton)                 └── Fullscreen mode
                                                                            (excluded dari capture)
```

### Alur koneksi

1. **Host** mendaftar ke relay dengan **Device ID** + **Auth Token** (di-hash SHA-256)
2. **Controller** memasukkan **Device ID** + **Auth Token** → relay memverifikasi → terhubung
3. Frames layar dikirim via **TLS**, view-only — tanpa kontrol mouse/keyboard

---

## 🚀 Cara Pakai

### Skenario 1 — Pakai relay yang sudah ada

| Langkah | Di mana | Lakukan |
|---------|---------|---------|
| 1 | **Host** (PC klien) | Jalankan `RdpV.Host.Setup.exe` (klik kanan → Run as Administrator) → isi Relay host/port/CA → **Pasang Sekarang** → catat **Device ID** & **Auth Token** |
| 2 | **Controller** (PC penonton) | Jalankan `RdpV.Controller.Setup.exe` → buka **RdpV Controller** → isi Relay host/port/CA + Device ID + Auth Token → **Connect** |
| 3 | — | Selesai melihat? Klik **Disconnect** |

### Skenario 2 — Pasang relay sendiri

```powershell
# Install relay sebagai Windows service (auto-start)
powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Port 8443

# Hapus relay
powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Uninstall
```

Script otomatis melakukan:
- ✅ Mem-publish relay + install sebagai service `RdpV.Relay` (auto-start)
- ✅ Membuka port di Windows Firewall
- ✅ Membuat sertifikat self-signed → menampilkan `relay-ca.crt` untuk dibagikan

---

## ✨ Fitur

| Fitur | Keterangan |
|-------|-----------|
| 🔒 **View-only** | Tidak ada kontrol mouse/keyboard, tidak ada transfer file |
| 🔐 **TLS end-to-end** | Semua komunikasi terenkripsi |
| 🛡️ **Token rahasia** | Akses hanya dengan Device ID + Auth Token (di-hash, tidak pernah plain) |
| 🩺 **Host Indicator** | Tray icon hijau saat ada penonton, normal saat idle |
| 📐 **Resolution scaling** | Pilih resolusi streaming sesuai kebutuhan |
| 🖵 **Fullscreen** | Mode layar penuh, otomatis mengecualikan jendela Controller dari capture |
| ⚡ **Auto-start** | Host & Relay jalan sebagai Windows service saat boot |
| 📦 **Self-extracting** | Satu file .exe, tanpa dependensi tambahan |

---

## 🖥️ Persyaratan Sistem

- Windows 10 / 11 (x64)
- Tidak perlu .NET Runtime (sudah self-contained)

---

## 📚 Struktur Project

```
├── src/
│   ├── HostApp/          # Service Host (register, stream layar, view-only)
│   ├── HostIndicator/    # Tray icon indikator (hijau saat ada penonton)
│   ├── HostSetup/        # Installer Host (GUI)
│   ├── ControllerApp/    # Aplikasi Controller (WPF)
│   ├── ControllerSetup/  # Installer Controller
│   ├── RelayServer/      # Relay server (TLS, bridging, Windows service)
│   ├── SetupLib/         # Library self-extractor
│   └── SharedLibrary/    # Shared config, protocol, security
├── scripts/
│   ├── build-download-site.ps1   # Build semua installer ke website/download
│   ├── install-relay-service.ps1 # Install relay sebagai service
│   └── serve-site.ps1            # (opsional) serve website di LAN
└── website/
    ├── index.html        # Landing page download
    ├── QUICKSTART.md     # Panduan cepat (klien)
    ├── PANDUAN.md        # Panduan lengkap
    └── README.md         # Dokumen ini
```

---

## 🛠️ Bagi Developer

### Persyaratan Build

- .NET 8 SDK (x64)
- Windows 10/11

### Build semua installer

```powershell
.\scripts\build-download-site.ps1
```

### Jalankan relay dari source

```bash
# Publish
dotnet publish src/RelayServer -c Release -r win-x64 --self-contained

# Jalankan (console)
src/RelayServer/bin/Release/net8.0-windows/win-x64/publish/RdpV.RelayServer.exe 8443

# Jalankan sebagai service
src/RelayServer/bin/Release/net8.0-windows/win-x64/publish/RdpV.RelayServer.exe --service 8443
```

### Sertifikat relay custom

```powershell
.\RdpV.RelayServer.exe 8443 --cert C:\certs\relay.pfx --certpass "rahasia"
```

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Tidak bisa connect | Pastikan relay host/port/CA benar, relay online, port terbuka |
| Layar dalam layar (feedback loop) | Host & Controller di PC sama → pakai mode **Fullscreen** |
| Sempat connect lalu putus | Cek `sc query RdpV.Host` masih running, relay online |
| Resolusi tidak sesuai | Host hanya mengirim resolusi native monitor |

---

## 🤝 Kontribusi

1. Fork repository
2. Buat branch fitur (`git checkout -b feat/nama-fitur`)
3. Commit perubahan (`git commit -m "feat: tambah hal baru"`)
4. Push (`git push origin feat/nama-fitur`)
5. Buka Pull Request

---

## 📄 Lisensi

[MIT License](LICENSE) — bebas dipakai, dimodifikasi, dan didistribusikan.

---

## 🙋 Support

- **Issue / bug:** [GitHub Issues](https://github.com/drcreatordev/rdpv/issues)
- **Panduan pengguna:** [PANDUAN.md](https://drcreatordev.github.io/rdpv/PANDUAN.md)

---

<p align="center">
  <sub>Dibuat dengan ❤️ menggunakan .NET 8 — <b>RdpV</b></sub>
</p>
