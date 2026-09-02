# RdpV — Panduan Pemasangan & Penggunaan

RdpV = Remote Desktop **view-only** (hanya melihat layar, tanpa kontrol mouse/keyboard,
tanpa transfer file). Aman: koneksi dienkripsi TLS dan butuh token yang hanya dimiliki
pemilik PC.

---

## Komponen (yang perlu didownload dari website ini)

| File | Untuk siapa | Fungsi |
|------|-------------|--------|
| `RdpV.Host.Setup.exe` | PC yang **layarnya mau dilihat** (mis. laptop klien) | Install di PC korban/klien agar layarnya bisa di-stream |
| `RdpV.Controller.Setup.exe` | PC yang **ingin melihat** (mis. PC Anda / teknisi) | Aplikasi untuk melihat layar Host |
| `RdpV.HostIndicator.exe` | (opsional) PC yang sama dengan Host | Ikon tray: hijau = ada yang melihat, normal = idle |
| `RdpV.RelayServer.exe` + `install-relay-service.ps1` | **Penyedia relay** (opsional) | Untuk operator/klien yang ingin menjalankan relay sendiri |

---

## Skenario A — Pakai relay yang sudah disediakan

1. **Di PC yang layarnya mau dilihat (Host):**
   - Install `RdpV.Host.Setup.exe` (klik **Yes** saat UAC/minta admin).
   - Setup perlu info dari penyedia relay:
     - **Relay host** = alamat relay (mis. `relay.contoh.com` atau IP publik)
     - **Relay port** = port relay (contoh `8443`)
     - **Relay CA** = file `relay-ca.crt` yang dibagikan penyedia
   - Catat **Device ID** dan **Auth token** yang ditampilkan/ada di pengaturan Host.
     Token ini RAHASIA — hanya beri ke orang yang boleh melihat layar.

2. **Di PC yang ingin melihat (Controller):**
   - Install `RdpV.Controller.Setup.exe`.
   - Buka aplikasi **RdpV Controller**.
   - Isi: **Relay host**, **Port**, **Device ID**, **Auth token** (dari Host), lalu pilih **Trusted CA…** → pilih file `relay-ca.crt`.
   - Klik **Connect** → layar Host akan tampil (view-only).
   - Pilih **Resolution** sesuai kebutuhan; **Fullscreen** untuk layar penuh (keluar dengan **Esc** atau tombol **Exit Fullscreen**).

> Rating/HostIndikator opsional: jalankan `RdpV.HostIndicator.exe` di PC Host di
> session yang sama supaya ada indikator tray bahwa sedang dilihat.

---

## Skenario B — Pasang relay sendiri (operator / klien yang mau mandiri)

Relay adalah "tengah" yang menghubungkan Host dan Controller. Relay harus selalu
online dan bisa dijangkau dari internet (perlu **IP publik / VPS / port forward**).

1. **Publish relay** (butuh .NET 8 SDK) atau pakai `RdpV.RelayServer.exe` dari folder download:
   ```
   powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Port 8443
   ```
   Script ini:
   - mem-publish relay,
   - memasangnya sebagai **Windows service** `RdpV.Relay` (auto-start saat boot),
   - membuat sertifikat self-signed di folder `C:\ProgramData\RdpV\relay\.relay\`
     dan menulis `relay-ca.crt` di situ,
   - mulai service-nya.

2. **Buka port relay di firewall/NAT** (mis. `8443`) di mesin relay.

3. **Bagikan ke semua klien** file `relay-ca.crt` (dari
   `C:\ProgramData\RdpV\relay\.relay\relay-ca.crt`) — ini kunci kepercayaan.

4. **Tanpa script / pakai cert sendiri:**
   ```
   RdpV.RelayServer <port> [--cert <path.pfx> --certpass <password>]
   RdpV.RelayServer --service <port> [--cert ... --certpass ...]   # sebagai Windows service
   ```

5. Untuk **menghapus** service:
   ```
   powershell -ExecutionPolicy Bypass -File install-relay-service.ps1 -Uninstall
   ```

---

## Pemecahan masalah cepat

- **Tidak bisa connect:** pastikan relay host/port/CA benar, relay online, port terbuka,
  dan Device ID/token sesuai.
- **Layar kosong / feedback (layar dalam layar):** ini terjadi saat Host & Controller di
  **PC yang sama**. Gunakan mode **Fullscreen** (Controller otomatis mengecualikan
  jendelanya agar tidak ikut ter-capture).
- **Sempat terhubung lalu putus:** periksa Host service masih running
  (`sc query RdpV.Host`) dan relay online.
- **Revolusi melebihi monitor:** Host hanya mengirim resolusi setinggi monitor aslinya;
  memilih 4K pada monitor 1366x768 tetap ditampilkan sebagai 1366x768.
