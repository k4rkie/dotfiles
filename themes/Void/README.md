
![](Art/preview.png)

#### Installation

**From source (recommended):**
```bash
cd themes/Void
bash install.sh
```

**Or copy directly:**
```bash
sudo cp -r themes/Void /usr/share/themes/Void
# then compile CSS:
cd /usr/share/themes/Void
npx sass --no-source-map gtk-3.0/gtk.scss gtk-3.0/gtk.css
npx sass --no-source-map gtk-4.0/gtk.scss gtk-4.0/gtk.css
npx sass --no-source-map gnome-shell/gnome-shell.scss gnome-shell/gnome-shell.css
npx sass --no-source-map cinnamon/cinnamon.scss cinnamon/cinnamon.css
```

**Activate the theme:**
```bash
gsettings set org.gnome.desktop.interface gtk-theme "Void"
```

Requirements: [Dart Sass](https://sass-lang.com/dart-sass) (`npm install -g sass`).
