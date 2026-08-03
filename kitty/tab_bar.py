import subprocess
import time
from typing import List, Optional, Tuple

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

translate_map = str.maketrans({"~": ""})


def get_title(tab: TabBarData, index: int, max_title_length: int) -> str:
    title = tab.title.strip()
    
    if title.startswith("~") or title.startswith("/") or title == "Home":
        title = "zsh"
        
    # If there's a space, it's usually a command with arguments (e.g., 'nvim file.txt')
    if " " in title:
        title = title.split(" ")[0]

    if not title:
        title = "zsh"
    if len(title) > max_title_length:
        title = title[: max_title_length - 3] + "•••"
    return f" {index}:{title} "


class GhostBar:
    def __init__(self) -> None:
        opts = get_options()
        self.username = subprocess.run(
            ["whoami"], capture_output=True, text=True
        ).stdout.strip()

        self.tabs: List[TabBarData] = []
        self._cached_session: Optional[str] = None
        self._cache_time: float = 0.0

        self.inactive_tab_fg: int = as_rgb(color_as_int(opts.inactive_tab_foreground))
        self.inactive_tab_bg: int = as_rgb(color_as_int(opts.inactive_tab_background))
        self.active_tab_bg: int = as_rgb(color_as_int(opts.active_tab_background))
        self.active_tab_fg: int = as_rgb(color_as_int(opts.active_tab_foreground))
        self.tab_bar_fg: int = as_rgb(color_as_int(opts.inactive_tab_foreground))
        self.tab_bar_bg: int = as_rgb(color_as_int(opts.background))

    def _get_state(self, screen: Screen) -> Tuple[int, int]:
        return (screen.cursor.fg, screen.cursor.bg)

    def set_state(self, screen: Screen, state: Tuple[int, int]) -> None:
        screen.cursor.fg = state[0]
        screen.cursor.bg = state[1]

    def _get_session_name(self) -> Optional[str]:
        """Read KITTY_SESSION env var from the first window's child process."""
        now = time.monotonic()
        if now - self._cache_time < 2.0:
            return self._cached_session
        self._cache_time = now
        self._cached_session = None

        try:
            boss = get_boss()
            if not boss:
                return None
            tm = boss.active_tab_manager
            if not tm:
                return None
            for tab in tm:
                for window in tab:
                    try:
                        pid = window.child.pid
                        if pid:
                            with open(f'/proc/{pid}/environ', 'rb') as f:
                                for entry in f.read().split(b'\0'):
                                    if entry.startswith(b'KITTY_SESSION='):
                                        self._cached_session = entry.split(b'=', 1)[1].decode()
                                        return self._cached_session
                    except (OSError, PermissionError):
                        pass
                    break
                break
        except Exception:
            pass
        return None

    def draw_left(self, screen: Screen) -> int:
        state = self._get_state(screen)
        screen.cursor.bold = True
        screen.cursor.italic = False
        screen.cursor.x = 0

        # Show session name if in a session, otherwise username
        session_name = self._get_session_name()
        label = session_name if session_name else self.username

        self.set_state(screen, (self.active_tab_fg, self.active_tab_bg))
        screen.draw(f"  {label} ")
        self.set_state(screen, (self.active_tab_bg, state[1]))
        screen.draw("▌")

        self.set_state(screen, state)
        return screen.cursor.x

    def draw_tabs_right(
        self,
        screen: Screen,
        max_title_length: int,
    ) -> int:
        state = self._get_state(screen)

        # 1. Calculate total width of all tab blocks (no powerline caps)
        total_width = 0
        formatted_titles = []
        for i, tab in enumerate(self.tabs):
            t = get_title(tab, i + 1, max_title_length)
            formatted_titles.append(t)
            total_width += len(t)

        # 2. Align cursor to far right edge
        screen.cursor.x = max(0, screen.columns - total_width)

        # 3. Draw tabs as flat rectangular blocks (matching tmux style)
        for index, tab in enumerate(self.tabs):
            title = formatted_titles[index]

            if tab.is_active:
                screen.cursor.bold = True
                screen.cursor.italic = False
                self.set_state(screen, (self.active_tab_fg, self.active_tab_bg))
                screen.draw(title)
            else:
                screen.cursor.bold = False
                screen.cursor.italic = False
                self.set_state(screen, (self.inactive_tab_fg, self.inactive_tab_bg))
                screen.draw(title)

        self.set_state(screen, state)
        return screen.cursor.x

    def draw_tab(
        self,
        draw_data: DrawData,
        screen: Screen,
        tab: TabBarData,
        before: int,
        max_title_length: int,
        index: int,
        is_last: bool,
        extra_data: ExtraData,
    ) -> int:
        self.set_state(screen, (self.tab_bar_fg, self.tab_bar_bg))
        screen.cursor.bold = True

        if index == 1:
            screen.draw(" " * screen.columns)
            self.tabs = []
            self.draw_left(screen)

        self.tabs.append(tab)

        if is_last:
            self.draw_tabs_right(screen, max_title_length)

        return screen.cursor.x


bar = GhostBar()


def draw_tab(*args) -> int:
    return bar.draw_tab(*args)
