# 🎣 Auto Fish V1.0

> An ultra-fast, feature-rich auto fishing script for Roblox fishing games with a beautiful Rayfield UI interface.

## ✨ Features

### 🎣 Fishing Automation
- **Blatant Mode** - 3x faster fishing with parallel rod casting (still beta test, might not working)
- **Normal Mode** - Safer, regular-speed fishing
- **Auto Catch** - Additional spam catch for maximum speed
- **Smart Fishing Logic** - Optimized timing and rod management

### 💰 Economy & Trading
- **Auto Sell** - Automatically sells fish while keeping favorited ones safe
- **Auto Favorite** - Automatically favorites Mythic/Secret rarity fish
- **Configurable Delays** - Customize all timing settings

### 🌍 Teleportation System
14+ Locations including:
- Spawn
- Sisyphus Statue
- Coral Reefs
- Esoteric Depths
- Crater Island
- Lost Isle
- Weather Machine
- Tropical Grove
- Mount Hallow
- Treasure Room
- Kohana
- Underground Cellar
- Ancient Jungle
- Sacred Temple

### ⚙️ Performance & Safety
- **GPU Saver Mode** - Reduces VRAM usage and improves performance
- **Anti-AFK Protection** - Prevents being kicked for inactivity
- **Config Auto-Save** - Your settings are automatically saved
- **Error Handling** - Robust pcall protection throughout

### 🎨 User Interface
- Beautiful Rayfield UI
- Easy-to-use toggles and inputs
- Real-time status updates
- Organized tab system

## 📦 Installation

### Method 1: Direct Execution (Recommended)
```lua
loadstring(game:HttpGet('https://gist.githubusercontent.com/nandafjng/3bfcba477c5ff48f10bc59b02526e98a/raw/8474851fa3aa831a3c9708da696221a4e3e9a982/gistfile1.txt'))()
```

### Method 2: Manual Installation
1. Download `script.lua` from the repository
2. Copy the contents
3. Paste into your executor
4. Execute the script

## 🚀 Quick Start

1. **Launch the script** using one of the methods above
2. **Enable Auto Fish** in the Main tab
3. **(Optional)** Enable Blatant Mode for 3x faster fishing
4. **(Optional)** Enable Auto Sell to automatically sell fish
5. **(Optional)** Enable Auto Favorite to keep rare fish

## 📖 Usage Guide

### Basic Usage

#### Auto Fishing
```
Main Tab → Auto Fish (Toggle ON)
```
- Normal Mode: Safe, regular speed
- Blatant Mode: 3x faster, more obvious 

#### Auto Sell
```
Main Tab → Auto Sell (Toggle ON)
Main Tab → Sell Delay (Customize timing)
```
- Sells all non-favorited fish automatically
- Default: Every 30 seconds

#### Teleportation
```
Teleport Tab → Select Location → Click Button
```
- Instant teleport to any location
- No cooldowns

### Advanced Settings

#### Delays Configuration
| Setting | Default | Range | Description |
|---------|---------|-------|-------------|
| Fish Delay | 0.9s | 0.1-10s | Time to wait for fish to bite |
| Catch Delay | 0.2s | 0.1-10s | Time between catch attempts |
| Sell Delay | 30s | 10-300s | Time between auto-sells |

#### Auto Favorite
```
Settings Tab → Auto Favorite (Toggle ON)
Settings Tab → Favorite Rarity (Select Mythic/Secret)
```
- Automatically favorites high-value fish
- Runs every 10 seconds
- Only favorites Mythic and Secret rarity

#### GPU Saver
```
Settings Tab → GPU Saver Mode (Toggle ON)
```
- Reduces graphics quality
- Lowers FPS cap to 8
- Shows black screen overlay
- Great for low-end devices or background farming

## 🛠️ Configuration

Settings are automatically saved to:
```
OptimizedAutoFish/config_[YourUserID].json
```

### Default Configuration
```json
{
  "AutoFish": false,
  "AutoSell": false,
  "AutoCatch": false,
  "GPUSaver": false,
  "BlatantMode": false,
  "FishDelay": 0.9,
  "CatchDelay": 0.2,
  "SellDelay": 30,
  "TeleportLocation": "Sisyphus Statue",
  "AutoFavorite": true,
  "FavoriteRarity": "Mythic"
}
```

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details on:
- How to submit bug reports
- How to suggest new features
- Code style guidelines
- Pull request process

## 📝 Changelog

### Version 1.1 (Current)
- ✨ Added Blatant Mode (3x faster fishing)
- ✨ Added 14 teleport locations
- ✨ Added Auto Favorite system
- ✨ Added GPU Saver mode
- 🐛 Fixed network event initialization
- 🔧 Improved error handling
- 📚 Better code organization

## 🐛 Known Issues

- None currently! Report issues [here](https://github.com/yourusername/auto-fish-v4/issues)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This script is for educational purposes only. Use at your own risk. The authors are not responsible for any consequences of using this script, including but not limited to game bans or account restrictions.

## 🙏 Credits

- **Rayfield UI Library** - Beautiful UI framework
- **Contributors** - See [CONTRIBUTORS.md](CONTRIBUTORS.md)
- **Community** - For testing and feedback

## 📞 Support

- 🐛 **Bug Reports**: Go to discord server
- 💡 **Feature Requests**: go to discord server
- 💬 **Discussions**: go to discord server

## ⭐ Star History

If you find this project helpful, please consider giving it a star!

---

**Create By Rioo**