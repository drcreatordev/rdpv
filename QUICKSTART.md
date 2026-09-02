# RdpV — Panduan Singkat

## Yang Perlu Di-download

Buka **https://keyyz12.github.io/rdpv/** dan download:

| File | Untuk apa | Di mana pasang |
|------|-----------|----------------|
| `RdpV.Host.Setup.exe` | Server relay | PC/Server yang selalu online |
| `RdpV.Host.Setup.exe` | Host (PC yang mau ditonton) | Setiap PC klien |
| `RdpV.Controller.Setup.exe` | Controller (PC penonton) | PC teknisi/anda |
| `install-relay-service.ps1` | Install relay otomatis | PC/Server relay |

---

## Langkah 1 — Pasang Relay

> Relay = "tengah" yang menghubungkan Host dan Controller.
> Pasang di PC/Server yang **selalu online** dan punya **IP publik**.

1. Jalankan `install-relay-service.ps1` di PC/Server relay:
   ```
   powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Port 8443
   ```
2. Catat **alamat relay** (contoh: `relay.contoh.com` atau IP publik)
3. Catat **port** (default: `8443`)
4. Ambil file **`relay-ca.crt`** dari:
   ```
   C:\ProgramData\RdpV\relay\.relay\relay-ca.crt
   ```
   → Kirim file ini ke semua klien (Host & Controller)

---

## Langkah 2 — Pasang Host (PC Klien)

> Host = PC yang layarnya mau dilihat.

1. Jalankan `RdpV.Host.Setup.exe` (klik kanan → Run as Administrator)
2. Isi form:
   - **Relay host** = alamat relay dari Langkah 1
   - **Relay port** = port dari Langkah 1
   - **Relay CA** = klik "Pilih…" → cari file `relay-ca.crt`
3. Klik **Pasang Sekarang**
4. Catat **Device ID** dan **Auth Token** yang tampil
   → Kirim ke penonton (Controller)

---

## Langkah 3 — Pasang Controller (PC Penonton)

> Controller = PC yang dipakai melihat layar Host.

1. Jalankan `RdpV.Controller.Setup.exe`
2. Buka aplikasi **RdpV Controller**
3. Isi:
   - **Relay host** = alamat relay
   - **Relay port** = port relay
   - **Device ID** = dari Host (Langkah 2)
   - **Auth Token** = dari Host (Langkah 2)
   - **Trusted CA** = pilih file `relay-ca.crt`
4. Klik **Connect**
5. Selesai! Layar Host sekarang terlihat.

---

## Tips

- **Host Indicator** (opsional): jalankan `RdpV.HostIndicator.exe` di PC Host
  → icon tray berubah hijau saat ada yang melihat
- **Fullscreen**: tekan `Ctrl+Shift+F11` atau klik tombol Fullscreen
- **Resolusi**: pilih resolusi sesuai kebutuhan di dropdown
- **Disconnect**: klik Disconnect di Controller → layar berhenti

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Tidak bisa connect | Cek relay host/port/CA benar, relay online, port terbuka |
| Layar dalam layar | Host & Controller di PC sama → pakai Fullscreen |
| Sempat connect lalu putus | Cek relay masih online, Host service masih jalan |
