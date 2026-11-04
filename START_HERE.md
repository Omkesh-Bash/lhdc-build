# 📖 START HERE – LHDC PipeWire Build Guide

**You have successfully built custom PipeWire with LHDC v5 codec support!**

---

## 🎯 Choose Your Path

### 🟢 **Path 1: "I want to test right now"**
⏱️ **Time**: 2 minutes  
📄 **Read**: None (just run commands)  
👉 **Action**:
```bash
cd /path/to/lhdc-build

# Verify codec loads
bash run-lhdc-env.sh ldd /lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so

# Expected output contains:
# liblhdcv5.so => /lhdc-install/lib/liblhdcv5.so
```
✅ **If this works**, your build is ready!

---

### 🟡 **Path 2: "I want to understand what was built"**
⏱️ **Time**: 5–10 minutes  
📄 **Read**: [README_FINAL.md](README_FINAL.md) or [STATUS_REPORT.md](STATUS_REPORT.md)  
✅ **Then**: Proceed to Path 1 test  
🎯 **Why**: Get the big picture before testing

---

### 🔵 **Path 3: "I want detailed testing & integration guide"**
⏱️ **Time**: 15 minutes reading + testing  
📄 **Read**: [LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md)  
🎯 **Why**: Covers safe testing, Bluetooth integration, rollback procedures

---

### 🟣 **Path 4: "I want to rebuild or modify the build"**
⏱️ **Time**: Full build time depends on system  
📄 **Read**: [BUILD_PROCEDURE.md](BUILD_PROCEDURE.md)  
🎯 **Why**: Step-by-step guide to understand and rebuild everything

---

## 📚 Document Index

| Document | Use When | Time |
|----------|----------|------|
| **[README_FINAL.md](README_FINAL.md)** | Want overview + quick start | 5 min |
| **[STATUS_REPORT.md](STATUS_REPORT.md)** | Want detailed project status | 10 min |
| **[BUILD_PROCEDURE.md](BUILD_PROCEDURE.md)** | Need to rebuild or understand process | 15 min |
| **[LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md)** | Ready to test or integrate | 20 min |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Need commands quick (bookmark this!) | 2 min |

---

## ⚡ One-Line Summary

You have **PipeWire 1.7.0 + LHDC codec** compiled and ready in `~/lhdc-install/`, completely separate from system audio.

---

## 🚦 Traffic Light Guide

### 🟢 Everything Is Ready When:
- ✅ Wrapper script (`run-lhdc-env.sh`) exists
- ✅ LHDC codec plugin exists at `lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so`
- ✅ Custom PipeWire binary exists at `bin/pipewire`
- ✅ `ldd` shows `liblhdcv5.so` resolved correctly

**Current Status**: ✅ All green!

---

## 🎓 5-Minute Orientation

### What is this?
- Custom PipeWire daemon with LHDC Bluetooth codec support
- Built from official PipeWire source code (GitHub)
- Installed to your home directory (safe, isolated)

### Why should I care?
- LHDC is a high-quality Bluetooth audio codec
- Enables better audio on compatible Bluetooth devices (Sony, etc.)
- System audio remains untouched (can rollback anytime)

### How do I use it?
```bash
# Always use the wrapper script:
bash run-lhdc-env.sh /lhdc-install/bin/<command>

# Examples:
bash run-lhdc-env.sh /lhdc-install/bin/pw-cli info core
bash run-lhdc-env.sh /lhdc-install/bin/pw-dump
bash run-lhdc-env.sh /lhdc-install/bin/pw-top
```

### Is my system safe?
**Yes! 100% safe.** System files untouched. Can rollback in 1 command.

---

## 🛣️ Recommended Reading Order

1. **First**: This file (you're reading it!)
2. **Second**: [README_FINAL.md](README_FINAL.md) – 5 min overview
3. **Third**: [LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md) – When ready to test
4. **Reference**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) – As needed

---

## ❓ FAQ

**Q: How do I test this?**  
A: Run Path 1 above (2 minutes) or see "Quick Start" in [README_FINAL.md](README_FINAL.md)

**Q: Will this affect my system audio?**  
A: No. Everything is in `~/lhdc-install`. System untouched.

**Q: How do I use this with my Bluetooth device?**  
A: See [LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md) § Phase 2

**Q: How do I rebuild?**  
A: See [BUILD_PROCEDURE.md](BUILD_PROCEDURE.md)

**Q: What if something breaks?**  
A: See [LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md) § Rollback Instructions (1 command)

---

## 🎯 Next 5 Minutes

### Do This:
```bash
cd /path/to/lhdc-build
bash run-lhdc-env.sh /lhdc-install/bin/pipewire --version
# Should print: Compiled with libpipewire 1.7.0
```

### Then Read:
- [README_FINAL.md](README_FINAL.md) – Next 5 minutes
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) – Bookmark for later

### Then Decide:
- **Happy with quick test?** → You're done! Come back to LHDC_TESTING_GUIDE.md when ready for real testing
- **Want to understand more?** → Read [STATUS_REPORT.md](STATUS_REPORT.md)
- **Ready to integrate?** → Read [LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md)

---

## 📌 Key Files

| File | Size | Purpose |
|------|------|---------|
| `run-lhdc-env.sh` | 1 KB | Environment wrapper (use for ALL tools) |
| `README_FINAL.md` | 8 KB | Complete overview + quick start |
| `STATUS_REPORT.md` | 12 KB | Detailed project status |
| `BUILD_PROCEDURE.md` | 15 KB | Full rebuild procedure |
| `LHDC_TESTING_GUIDE.md` | 18 KB | Testing & integration guide |
| `QUICK_REFERENCE.md` | 4 KB | Command cheat sheet |

---

## 🎉 You're All Set!

**Status**: ✅ Build complete  
**System Safety**: ✅ 100% protected  
**Ready to Test**: ✅ Yes  

Pick a path above and get started! 🚀

---

**Questions?** Read the relevant document. **Still stuck?** Re-read [QUICK_REFERENCE.md](QUICK_REFERENCE.md).  
**Success?** Enjoy your LHDC-enabled PipeWire build!
