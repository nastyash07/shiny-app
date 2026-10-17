# ============================================================
#   АНАЛИЗ ДАННЫХ · PREMIUM EDITION v3.4
# ============================================================

library(shiny)
library(bslib)
library(DT)
library(ggplot2)
library(readxl)

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bootswatch = "cyborg",
    bg = "#0A0A0F", fg = "#E4E4E7",
    primary = "#8B5CF6", secondary = "#22D3EE",
    base_font = font_google("Inter"),
    heading_font = font_google("Space Grotesk"),
    code_font = font_google("JetBrains Mono")
  ),
  
  tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap"),
    
    tags$script(HTML("
      function toggleTheme() {
        document.body.classList.toggle('light-theme');
        var isLight = document.body.classList.contains('light-theme');
        var btn = document.getElementById('theme_icon');
        btn.textContent = isLight ? '🌙' : '☀️';
        if (window.Shiny) {
          Shiny.setInputValue('theme_state', isLight ? 'light' : 'dark', {priority: 'event'});
        }
      }

      document.addEventListener('DOMContentLoaded', function() {
        if (window.Shiny) {
          setTimeout(function() {
            Shiny.setInputValue('theme_state', 'dark', {priority: 'event'});
          }, 150);
        }

        var panel = document.getElementById('console_panel');
        if (!panel) return;
        var header = panel.querySelector('.console-header');
        if (!header) return;

        var isDragging = false;
        var startX, startY, offsetX, offsetY, mouseDownTime;

        header.addEventListener('mousedown', function(e) {
          if (e.target.closest('.console-btn')) return;
          var rect = panel.getBoundingClientRect();
          startX = e.clientX; startY = e.clientY;
          offsetX = e.clientX - rect.left;
          offsetY = e.clientY - rect.top;
          mouseDownTime = Date.now();
          isDragging = true;
          panel.style.transition = 'none';
          document.body.style.cursor = 'grabbing';
          document.body.style.userSelect = 'none';
          e.preventDefault();
        });

        document.addEventListener('mousemove', function(e) {
          if (!isDragging) return;
          var newLeft = e.clientX - offsetX;
          var newTop = e.clientY - offsetY;
          var maxX = window.innerWidth - panel.offsetWidth;
          var maxY = window.innerHeight - panel.offsetHeight;
          newLeft = Math.max(0, Math.min(newLeft, maxX));
          newTop = Math.max(0, Math.min(newTop, maxY));
          panel.style.left = newLeft + 'px';
          panel.style.top = newTop + 'px';
          panel.style.bottom = 'auto';
          panel.style.right = 'auto';
        });

        document.addEventListener('mouseup', function(e) {
          if (!isDragging) return;
          var dx = Math.abs(e.clientX - startX);
          var dy = Math.abs(e.clientY - startY);
          var dt = Date.now() - mouseDownTime;
          isDragging = false;
          panel.style.transition = '';
          document.body.style.cursor = '';
          document.body.style.userSelect = '';
          if (dx < 5 && dy < 5 && dt < 300) {
            panel.classList.toggle('collapsed');
          }
        });

        window.addEventListener('resize', function() {
          if (!panel) return;
          var rect = panel.getBoundingClientRect();
          var maxX = window.innerWidth - panel.offsetWidth;
          var maxY = window.innerHeight - panel.offsetHeight;
          if (rect.left > maxX) panel.style.left = Math.max(0, maxX) + 'px';
          if (rect.top > maxY) panel.style.top = Math.max(0, maxY) + 'px';
        });
      });
    ")),
    
    tags$style(HTML("
      :root {
        --app-bg: #0A0A0F;
        --app-fg: #E4E4E7;
        --app-muted: #A1A1AA;
        --app-subtle: #71717A;
        --card-bg: rgba(20, 20, 28, 0.75);
        --card-border: rgba(139, 92, 246, 0.18);
        --card-border-hover: rgba(139, 92, 246, 0.4);
        --accent: #8B5CF6;
        --accent-2: #22D3EE;
        --accent-3: #6366F1;
        --accent-fg: #C4B5FD;
        --accent-glow: rgba(139, 92, 246, 0.35);
        --result-bg: linear-gradient(135deg, rgba(139,92,246,0.1), rgba(34,211,238,0.05));
        --input-bg: rgba(10, 10, 15, 0.8);
        --input-bg-focus: rgba(10, 10, 15, 1);
        --input-border: rgba(139, 92, 246, 0.25);
        --console-bg: rgba(10, 10, 15, 0.95);
        --console-header: rgba(139, 92, 246, 0.12);
        --header-grad-1: rgba(139, 92, 246, 0.14);
        --header-grad-2: rgba(34, 211, 238, 0.08);
        --header-border: rgba(139, 92, 246, 0.25);
        --header-text-grad: linear-gradient(135deg, #FFFFFF 0%, #C4B5FD 50%, #67E8F9 100%);
        --btn-text: #FFFFFF;
        --label-color: #A1A1AA;
        --radio-text: #A1A1AA;
        --radio-text-active: #E4E4E7;
        --card-header-color: #C4B5FD;
        --table-empty-color: #71717A;
        --table-text: #E4E4E7;
        --table-text-muted: #A1A1AA;
      }

      body.light-theme {
        --app-bg: #F1F5F9;
        --app-fg: #0F172A;
        --app-muted: #475569;
        --app-subtle: #64748B;
        --card-bg: rgba(255, 255, 255, 0.98);
        --card-border: rgba(74, 108, 247, 0.25);
        --card-border-hover: rgba(74, 108, 247, 0.5);
        --accent: #4A6CF7;
        --accent-2: #06B6D4;
        --accent-3: #7B4AFC;
        --accent-fg: #4A6CF7;
        --accent-glow: rgba(74, 108, 247, 0.25);
        --result-bg: linear-gradient(135deg, rgba(74,108,247,0.08), rgba(6,182,212,0.05));
        --input-bg: #FFFFFF;
        --input-bg-focus: #FFFFFF;
        --input-border: rgba(74, 108, 247, 0.45);
        --console-bg: rgba(30, 30, 40, 0.98);
        --console-header: rgba(74, 108, 247, 0.1);
        --header-grad-1: rgba(74, 108, 247, 0.1);
        --header-grad-2: rgba(6, 182, 212, 0.08);
        --header-border: rgba(74, 108, 247, 0.2);
        --header-text-grad: linear-gradient(135deg, #1E293B 0%, #4A6CF7 50%, #06B6D4 100%);
        --btn-text: #FFFFFF;
        --label-color: #1E293B;
        --radio-text: #1E293B;
        --radio-text-active: #0F172A;
        --card-header-color: #4A6CF7;
        --table-empty-color: #64748B;
        --table-text: #0F172A;
        --table-text-muted: #475569;
      }

      html, body {
        background: var(--app-bg) !important;
        color: var(--app-fg) !important;
        font-family: 'Inter', sans-serif;
        min-height: 100vh;
        transition: background 0.4s ease, color 0.4s ease;
      }
      body::before {
        content: '';
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background:
          radial-gradient(circle at 15% 10%, var(--header-grad-1), transparent 45%),
          radial-gradient(circle at 85% 90%, var(--header-grad-2), transparent 45%);
        pointer-events: none;
        z-index: 0;
      }
      .container-fluid {
        position: relative;
        z-index: 1;
        padding: 24px 36px 300px 36px;
        max-width: 1500px;
      }
      * { box-sizing: border-box; }

      h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 {
        font-family: 'Space Grotesk', sans-serif !important;
        color: var(--app-fg);
      }
      .btn, button, .action-button,
      .btn-primary, .btn-default, .btn-outline-secondary,
      input[type='submit'], input[type='button'] {
        font-family: 'Space Grotesk', sans-serif !important;
      }

      .main-header {
        position: relative;
        padding: 44px 48px;
        border-radius: 24px;
        background: linear-gradient(135deg, var(--header-grad-1), var(--header-grad-2));
        border: 1px solid var(--header-border);
        margin-bottom: 32px;
        overflow: hidden;
        box-shadow: 0 24px 80px var(--accent-glow);
      }
      .main-header h1 {
        margin: 0;
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 700;
        font-size: 42px;
        letter-spacing: -0.02em;
        background: var(--header-text-grad);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
      }
      .main-header p {
        margin: 10px 0 0 0;
        color: var(--app-muted);
        font-size: 16px;
      }
      .badge-premium {
        display: inline-block;
        margin-top: 16px;
        padding: 6px 14px;
        background: var(--header-grad-1);
        border: 1px solid var(--header-border);
        border-radius: 100px;
        color: var(--accent-fg);
        font-size: 12px;
        font-weight: 600;
        letter-spacing: 0.05em;
        text-transform: uppercase;
      }
      .theme-toggle {
        position: absolute;
        top: 24px; right: 24px;
        width: 48px; height: 48px;
        border-radius: 50%;
        background: var(--card-bg);
        border: 1px solid var(--card-border);
        color: var(--app-fg);
        font-size: 20px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        backdrop-filter: blur(10px);
        z-index: 10;
      }
      .theme-toggle:hover {
        transform: scale(1.1) rotate(15deg);
        border-color: var(--accent);
        box-shadow: 0 0 24px var(--accent-glow);
      }

      .nav-pills { gap: 10px; margin-bottom: 24px; flex-wrap: wrap; }
      .nav-pills .nav-link {
        background: var(--card-bg);
        backdrop-filter: blur(10px);
        border: 1px solid var(--card-border);
        border-radius: 14px;
        padding: 12px 24px;
        color: var(--app-muted);
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 600;
        font-size: 15px;
        transition: all 0.25s ease;
      }
      .nav-pills .nav-link:hover {
        color: var(--app-fg);
        border-color: var(--card-border-hover);
        transform: translateY(-2px);
        box-shadow: 0 8px 24px var(--accent-glow);
      }
      .nav-pills .nav-link.active {
        background: linear-gradient(135deg, var(--accent), var(--accent-2));
        border-color: transparent;
        color: var(--btn-text);
        box-shadow: 0 12px 32px var(--accent-glow);
      }

      .card {
        background: var(--card-bg) !important;
        backdrop-filter: blur(20px);
        border: 1px solid var(--card-border) !important;
        border-radius: 20px !important;
        box-shadow: 0 4px 24px rgba(0,0,0,0.15);
        transition: all 0.3s ease;
        overflow: hidden;
      }
      .card:hover {
        border-color: var(--card-border-hover) !important;
        box-shadow: 0 12px 40px var(--accent-glow);
        transform: translateY(-3px);
      }
      .card-header {
        background: linear-gradient(180deg, var(--header-grad-1), transparent) !important;
        border-bottom: 1px solid var(--card-border) !important;
        padding: 20px 24px !important;
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: 0.03em;
        text-transform: uppercase;
        color: var(--card-header-color) !important;
      }
      .card-body { padding: 24px !important; color: var(--app-fg); }

      .form-control, .form-select, select.form-control, textarea.form-control {
        background: var(--input-bg) !important;
        border: 1px solid var(--input-border) !important;
        border-radius: 12px !important;
        color: var(--app-fg) !important;
        padding: 12px 16px !important;
        font-family: 'Inter', sans-serif;
        font-size: 14px;
        transition: all 0.2s;
        box-shadow: none !important;
      }
      .form-control::placeholder { color: var(--app-subtle) !important; }
      .form-control:focus, .form-select:focus, textarea.form-control:focus {
        border-color: var(--accent) !important;
        box-shadow: 0 0 0 4px var(--accent-glow) !important;
        background: var(--input-bg-focus) !important;
        color: var(--app-fg) !important;
      }
      label, .control-label { 
        color: var(--label-color) !important; 
        font-weight: 500; 
        font-size: 13px;
        margin-bottom: 6px;
      }

      .shiny-input-radiogroup .shiny-options-group {
        display: flex !important;
        flex-wrap: wrap !important;
        gap: 10px !important;
        align-items: center !important;
      }
      .shiny-input-radiogroup .radio-inline,
      .shiny-input-radiogroup .radio,
      .shiny-input-radiogroup .checkbox-inline,
      .shiny-input-radiogroup .checkbox {
        display: inline-flex !important;
        align-items: center !important;
        margin: 0 !important;
        padding: 0 !important;
        background: transparent !important;
        border: none !important;
      }
      .shiny-input-radiogroup .radio-inline > label,
      .shiny-input-radiogroup .radio > label {
        display: inline-flex !important;
        align-items: center !important;
        gap: 8px !important;
        margin: 0 !important;
        padding: 10px 16px !important;
        background: var(--input-bg) !important;
        border: 1px solid var(--input-border) !important;
        border-radius: 12px !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        font-size: 13px !important;
        color: var(--radio-text) !important;
        white-space: nowrap !important;
        font-weight: 500 !important;
      }
      .shiny-input-radiogroup .radio-inline > label:hover,
      .shiny-input-radiogroup .radio > label:hover {
        border-color: var(--accent) !important;
        color: var(--app-fg) !important;
        transform: translateY(-1px);
      }
      .shiny-input-radiogroup .radio-inline:has(input:checked) > label,
      .shiny-input-radiogroup .radio:has(input:checked) > label {
        border-color: var(--accent) !important;
        background: linear-gradient(135deg, var(--header-grad-1), transparent) !important;
        color: var(--radio-text-active) !important;
        box-shadow: 0 4px 12px var(--accent-glow) !important;
      }
      .shiny-input-radiogroup input[type='radio'] {
        margin: 0 !important;
        accent-color: var(--accent) !important;
        cursor: pointer !important;
        width: 16px !important;
        height: 16px !important;
      }
      .shiny-input-radiogroup span {
        color: inherit !important;
        font-size: 13px !important;
      }

      .form-group.shiny-input-container:has(input[type='file']) {
        width: 100%;
      }
      .form-group.shiny-input-container:has(input[type='file']) .input-group {
        display: flex !important;
        align-items: stretch !important;
        width: 100% !important;
        border-radius: 12px !important;
        overflow: hidden;
        border: 1px solid var(--input-border);
      }
      .form-group.shiny-input-container:has(input[type='file']) .input-group .btn-file,
      .form-group.shiny-input-container:has(input[type='file']) .input-group .btn-file .btn,
      .form-group.shiny-input-container:has(input[type='file']) .input-group label.btn,
      .form-group.shiny-input-container:has(input[type='file']) .input-group .btn-primary {
        height: 48px !important;
        min-height: 48px !important;
        padding: 0 24px !important;
        border-radius: 0 !important;
        font-size: 14px !important;
        line-height: 48px !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        box-shadow: none !important;
        margin: 0 !important;
        border: none !important;
        background: linear-gradient(135deg, var(--accent), var(--accent-3)) !important;
        color: #FFFFFF !important;
        white-space: nowrap !important;
        position: relative;
        overflow: hidden;
        font-weight: 600 !important;
        font-family: 'Space Grotesk', sans-serif !important;
      }
      .form-group.shiny-input-container:has(input[type='file']) .input-group .btn-file input[type='file'] {
        position: absolute !important;
        top: 0; left: 0;
        width: 100%; height: 100%;
        opacity: 0;
        cursor: pointer;
        font-size: 200px;
      }
      .form-group.shiny-input-container:has(input[type='file']) .input-group input[type='text'],
      .form-group.shiny-input-container:has(input[type='file']) .input-group .form-control {
        height: 48px !important;
        min-height: 48px !important;
        border-radius: 0 !important;
        border: none !important;
        border-left: 1px solid var(--input-border) !important;
        font-size: 14px !important;
        padding: 0 16px !important;
        display: flex !important;
        align-items: center !important;
        margin: 0 !important;
        background: var(--input-bg) !important;
        color: var(--app-fg) !important;
        flex: 1;
      }

      .btn-primary, .btn-default, .action-button {
        background: linear-gradient(135deg, var(--accent), var(--accent-3)) !important;
        border: none !important;
        border-radius: 12px !important;
        padding: 12px 28px !important;
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 600 !important;
        font-size: 14px !important;
        color: var(--btn-text) !important;
        box-shadow: 0 8px 24px var(--accent-glow) !important;
        transition: all 0.25s ease;
      }
      .btn-primary:hover, .btn-default:hover, .action-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 32px var(--accent-glow) !important;
        filter: brightness(1.1);
      }
      .btn-outline-secondary {
        background: transparent !important;
        border: 1px solid var(--input-border) !important;
        color: var(--app-muted) !important;
        border-radius: 12px !important;
        padding: 10px 20px !important;
        font-weight: 500 !important;
        transition: all 0.2s;
        font-family: 'Space Grotesk', sans-serif !important;
      }
      .btn-outline-secondary:hover {
        border-color: var(--accent) !important;
        color: var(--app-fg) !important;
      }

      .result-box {
        background: var(--result-bg);
        border: 1px solid var(--card-border);
        border-left: 3px solid var(--accent);
        padding: 20px 24px;
        border-radius: 14px;
        margin-top: 16px;
        font-size: 15px;
        color: var(--app-fg);
        animation: fadeIn 0.4s ease;
      }
      .result-box p { margin: 8px 0; color: var(--app-muted); font-size: 14px; }
      .result-value {
        font-family: 'Space Grotesk', sans-serif;
        color: var(--accent-2);
        font-weight: 700;
        font-size: 22px;
        margin-left: 4px;
      }
      @keyframes fadeIn {
        from { opacity: 0; transform: translateY(6px); }
        to { opacity: 1; transform: translateY(0); }
      }
      hr { border-color: var(--card-border); }

      .nav-tabs {
        border-bottom: 1px solid var(--card-border);
        margin-bottom: 20px;
        gap: 4px;
      }
      .nav-tabs .nav-link {
        color: var(--app-muted);
        border: none;
        border-bottom: 2px solid transparent;
        padding: 10px 18px;
        font-weight: 500;
        font-family: 'Space Grotesk', sans-serif;
        background: transparent !important;
        transition: all 0.2s;
        border-radius: 8px 8px 0 0;
      }
      .nav-tabs .nav-link:hover { color: var(--accent-fg); }
      .nav-tabs .nav-link.active {
        color: var(--app-fg) !important;
        background: transparent !important;
        border-bottom-color: var(--accent) !important;
      }

      .console-panel {
        position: fixed;
        bottom: 20px;
        left: 20px;
        width: 400px;
        height: 260px;
        background: var(--console-bg);
        backdrop-filter: blur(20px);
        border: 1px solid var(--card-border);
        border-radius: 16px;
        z-index: 2000;
        display: flex;
        flex-direction: column;
        box-shadow: 0 24px 60px rgba(0,0,0,0.5);
        font-family: 'JetBrains Mono', monospace;
        overflow: hidden;
        transition: height 0.3s ease, box-shadow 0.3s;
      }
      .console-panel:hover {
        box-shadow: 0 28px 70px rgba(0,0,0,0.6), 0 0 40px var(--accent-glow);
      }
      .console-panel.collapsed { height: 44px; }
      .console-panel.collapsed .console-body { display: none; }
      .console-header {
        background: var(--console-header);
        padding: 12px 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid var(--card-border);
        cursor: grab;
        user-select: none;
      }
      .console-header:active { cursor: grabbing; }
      .console-header-left { display: flex; align-items: center; gap: 8px; }
      .console-dot {
        width: 10px; height: 10px; border-radius: 50%; display: inline-block;
      }
      .console-title {
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 600;
        font-size: 12px;
        color: var(--accent-fg);
        letter-spacing: 0.05em;
        text-transform: uppercase;
        margin-left: 6px;
      }
      .console-btn {
        background: var(--header-grad-1) !important;
        color: var(--accent-fg) !important;
        border: 1px solid var(--card-border) !important;
        padding: 4px 10px !important;
        border-radius: 8px !important;
        font-size: 11px !important;
        cursor: pointer;
        transition: all 0.15s !important;
        font-weight: 500 !important;
        font-family: 'Space Grotesk', sans-serif !important;
      }
      .console-btn:hover {
        background: var(--accent) !important;
        color: #FFFFFF !important;
        transform: none !important;
      }
      .console-body {
        flex: 1;
        overflow-y: auto;
        padding: 12px 16px;
        font-size: 12px;
        line-height: 1.6;
        color: #D4D4D8;
      }
      .console-body::-webkit-scrollbar { width: 6px; }
      .console-body::-webkit-scrollbar-thumb {
        background: var(--accent-glow);
        border-radius: 3px;
      }
      .log-entry {
        margin-bottom: 10px;
        padding-bottom: 8px;
        border-bottom: 1px dashed var(--card-border);
        animation: fadeIn 0.3s ease;
      }
      .log-time { color: #6A9955; font-size: 10px; font-weight: 500; }
      .log-code { color: #67E8F9; }
      .log-code::before { content: '> '; color: var(--accent); font-weight: 700; }
      .log-result { color: #4EC9B0; white-space: pre-wrap; margin-top: 3px; padding-left: 12px; }

      .app-footer {
        text-align: center;
        color: var(--app-subtle);
        font-size: 12px;
        font-family: 'Space Grotesk', sans-serif;
        padding: 20px 0;
      }

      .selectize-control.single .selectize-input {
        background: var(--input-bg) !important;
        border: 1px solid var(--input-border) !important;
        border-radius: 12px !important;
        color: var(--app-fg) !important;
        padding: 12px 16px !important;
        box-shadow: none !important;
      }
      .selectize-control.single .selectize-input.focus {
        border-color: var(--accent) !important;
        box-shadow: 0 0 0 4px var(--accent-glow) !important;
      }
      .selectize-dropdown {
        background: var(--card-bg) !important;
        border: 1px solid var(--card-border) !important;
        border-radius: 12px !important;
        color: var(--app-fg) !important;
      }
      .selectize-dropdown-content .option:hover,
      .selectize-dropdown-content .option.active {
        background: var(--header-grad-1) !important;
        color: var(--app-fg) !important;
      }

      table.dataTable { color: var(--table-text) !important; background: transparent !important; }
      table.dataTable thead th {
        background: var(--header-grad-1) !important;
        color: var(--accent-fg) !important;
        border-bottom: 1px solid var(--card-border) !important;
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 600;
      }
      table.dataTable tbody td {
        border-bottom: 1px solid var(--card-border) !important;
        color: var(--table-text) !important;
        background: transparent !important;
      }
      table.dataTable tbody tr,
      table.dataTable tbody tr.odd,
      table.dataTable tbody tr.even {
        background: transparent !important;
      }
      table.dataTable tbody tr:hover,
      table.dataTable tbody tr.odd:hover,
      table.dataTable tbody tr.even:hover {
        background: var(--header-grad-1) !important;
      }
      .dataTables_wrapper { color: var(--table-text) !important; background: transparent !important; }
      .dataTables_wrapper .dataTables_info,
      .dataTables_wrapper .dataTables_paginate,
      .dataTables_wrapper .dataTables_filter label,
      .dataTables_wrapper .dataTables_length label {
        color: var(--table-text-muted) !important;
      }
      .dataTables_wrapper .dataTables_filter input,
      .dataTables_wrapper .dataTables_length select {
        background: var(--input-bg) !important;
        color: var(--app-fg) !important;
        border: 1px solid var(--input-border) !important;
        border-radius: 8px !important;
        padding: 6px 12px !important;
      }
      .dataTables_wrapper .pagination .page-link {
        color: var(--table-text-muted) !important;
        background: transparent !important;
        border: 1px solid var(--card-border) !important;
      }
      .dataTables_wrapper .pagination .page-item.active .page-link {
        background: var(--accent) !important;
        color: #FFFFFF !important;
        border-color: var(--accent) !important;
      }

      body.light-theme table.dataTable,
      body.light-theme table.dataTable *,
      body.light-theme .dataTables_wrapper,
      body.light-theme .dataTables_wrapper * {
        color: #0F172A !important;
      }
      body.light-theme table.dataTable thead th,
      body.light-theme table.dataTable thead th * {
        color: #4A6CF7 !important;
      }
      body.light-theme .dataTables_wrapper .dataTables_info,
      body.light-theme .dataTables_wrapper .dataTables_filter label,
      body.light-theme .dataTables_wrapper .dataTables_length label {
        color: #475569 !important;
      }

      .dataTables_empty,
      table.dataTable tbody td.dataTables_empty {
        color: var(--table-empty-color) !important;
        background: transparent !important;
        font-style: italic;
        padding: 24px !important;
        text-align: center;
      }

      .export-row {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        margin-top: 16px;
        padding-top: 16px;
        border-top: 1px solid var(--card-border);
      }
    "))
  ),
  
  div(class = "main-header",
      div(class = "theme-toggle", id = "theme_icon", onclick = "toggleTheme();", "☀️"),
      h1("Анализ данных"),
      p("Интерактивная среда для вычислений, статистики и финансов"),
      div(class = "badge-premium", "R SHINY · PREMIUM EDITION v3.4")
  ),
  
  navset_pill(
    id = "main_tabs",
    
    nav_panel(
      "Математика",
      br(),
      layout_columns(
        col_widths = c(6, 6),
        card(
          card_header("Выберите задачу"),
          selectInput("math_task", NULL,
                      choices = c(
                        "Сумма двух чисел" = "sum",
                        "Факториал" = "fact",
                        "Проверка на простоту" = "prime",
                        "Площадь круга" = "circle",
                        "Площадь треугольника" = "triangle",
                        "Квадратное уравнение" = "quad"
                      ), width = "100%"),
          hr(),
          uiOutput("math_inputs"),
          br(),
          actionButton("math_calc", "Рассчитать",
                       class = "btn-primary", icon = icon("calculator"))
        ),
        card(
          card_header("Результат"),
          uiOutput("math_result")
        )
      )
    ),
    
    nav_panel(
      "Статистика",
      br(),
      layout_columns(
        col_widths = c(5, 7),
        card(
          card_header("Данные для анализа"),
          radioButtons("stats_mode", "Способ ввода:",
                       choices = c("Ввести вручную" = "manual",
                                   "Сгенерировать случайно" = "random",
                                   "Загрузить CSV" = "csv",
                                   "Загрузить Excel" = "excel"),
                       inline = TRUE),
          hr(),
          uiOutput("stats_inputs"),
          br(),
          actionButton("stats_calc", "Анализировать",
                       class = "btn-primary", icon = icon("chart-line"))
        ),
        card(
          card_header("Результаты и графики"),
          navset_tab(
            nav_panel("Статистика", uiOutput("stats_result")),
            nav_panel("График",
                      plotOutput("stats_plot", height = "400px"),
                      div(class = "export-row",
                          downloadButton("dl_plot_png", "📷 Скачать PNG",
                                         class = "btn-outline-secondary"))),
            nav_panel("Данные", DTOutput("stats_table")),
            nav_panel("Экспорт",
                      h4("Экспорт результатов",
                         style = "margin-bottom:20px;"),
                      p("Скачай отчёт, лог консоли или график в удобном формате.",
                        style = "color: var(--app-muted); margin-bottom: 24px;"),
                      div(class = "export-row",
                          downloadButton("dl_pdf", "📄 Отчёт PDF", class = "btn-primary"),
                          downloadButton("dl_txt", "📝 Лог (.txt)", class = "btn-outline-secondary"),
                          downloadButton("dl_csv", "📊 Данные (.csv)", class = "btn-outline-secondary"))
            )
          )
        )
      )
    ),
    
    nav_panel(
      "Финансы",
      br(),
      layout_columns(
        col_widths = c(6, 6),
        card(
          card_header("Выберите задачу"),
          selectInput("fin_task", NULL,
                      choices = c(
                        "Простые проценты" = "simple",
                        "Сложные проценты" = "compound",
                        "Аннуитетный платёж" = "pmt",
                        "Будущая стоимость аннуитета" = "fv",
                        "NPV" = "npv",
                        "IRR" = "irr",
                        "Срок окупаемости" = "payback",
                        "Конвертер валют" = "currency"
                      ), width = "100%"),
          hr(),
          uiOutput("fin_inputs"),
          br(),
          actionButton("fin_calc", "Рассчитать",
                       class = "btn-primary", icon = icon("coins"))
        ),
        card(
          card_header("Результат"),
          uiOutput("fin_result")
        )
      )
    ),
    
    nav_panel(
      "История",
      br(),
      card(
        card_header("Все выполненные операции"),
        div(class = "export-row",
            downloadButton("dl_history", "💾 Скачать историю",
                           class = "btn-outline-secondary"),
            actionButton("clear_history", "🗑 Очистить всё",
                         class = "btn-outline-secondary",
                         icon = NULL)),
        br(),
        DTOutput("history_table")
      )
    )
  ),
  
  br(), br(),
  div(class = "app-footer",
      "© 2025 · Интерактивная среда анализа данных"),
  
  tags$div(
    id = "console_panel",
    class = "console-panel",
    tags$div(
      class = "console-header",
      tags$div(
        class = "console-header-left",
        tags$span(class = "console-dot", style = "background:#FF5F56;"),
        tags$span(class = "console-dot", style = "background:#FFBD2E;"),
        tags$span(class = "console-dot", style = "background:#27C93F;"),
        tags$span(class = "console-title", "Консоль")
      ),
      actionButton("clear_console", "Очистить", class = "console-btn")
    ),
    tags$div(
      class = "console-body",
      uiOutput("console_output")
    )
  )
)


# ============================================================
# SERVER
# ============================================================

server <- function(input, output, session) {
  
  dt_lang <- list(
    search = "Поиск:",
    lengthMenu = "Показать _MENU_",
    info = "Строки _START_–_END_ из _TOTAL_",
    infoEmpty = "Нет записей",
    infoFiltered = "(отфильтровано из _MAX_)",
    zeroRecords = "Ничего не найдено",
    emptyTable = "Нет данных для отображения",
    paginate = list(previous = "‹", `next` = "›")
  )
  
  console_entries <- reactiveVal(list())
  history_entries <- reactiveVal(data.frame(
    Время = character(), Раздел = character(),
    Задача = character(), Результат = character(),
    stringsAsFactors = FALSE
  ))
  
  is_light <- reactive({
    identical(input$theme_state, "light")
  })
  
  add_log <- function(code, result, is_error = FALSE, section = "—", task = "—") {
    entry <- list(time = format(Sys.time(), "%H:%M:%S"),
                  code = code, result = result, is_error = is_error)
    cur <- console_entries()
    cur <- c(cur, list(entry))
    if (length(cur) > 20) cur <- cur[(length(cur)-19):length(cur)]
    console_entries(cur)
    
    h <- history_entries()
    new_row <- data.frame(
      Время = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      Раздел = section, Задача = task,
      Результат = paste(code, "→", result),
      stringsAsFactors = FALSE)
    history_entries(rbind(h, new_row))
  }
  
  trunc_str <- function(s, max_len = 60) {
    if (nchar(s) > max_len) paste0(substr(s, 1, max_len), "...") else s
  }
  
  observeEvent(input$clear_console, { console_entries(list()) })
  observeEvent(input$clear_history, {
    history_entries(data.frame(Время = character(), Раздел = character(),
                               Задача = character(), Результат = character(),
                               stringsAsFactors = FALSE))
    showNotification("История очищена", type = "message", duration = 2)
  })
  
  output$console_output <- renderUI({
    entries <- console_entries()
    if (length(entries) == 0) {
      return(HTML(
        "<div style='color:var(--app-subtle); padding:4px; font-size:11px;'>
          <span style='color:#6A9955;'># Консоль пуста</span><br>
          <span style='color:#6A9955;'># Выполни задачу — тут появится код и результат</span>
        </div>"))
    }
    html <- ""
    for (e in rev(entries)) {
      res_color <- if (e$is_error) "#F48771" else "#4EC9B0"
      html <- paste0(html,
                     "<div class='log-entry'>",
                     "<div class='log-time'>[", e$time, "]</div>",
                     "<div class='log-code'>", e$code, "</div>",
                     "<div class='log-result' style='color:", res_color, ";'>", e$result, "</div>",
                     "</div>")
    }
    HTML(paste0("<div>", html, "</div>"))
  })
  
  output$history_table <- renderDT({
    datatable(history_entries(),
              options = list(pageLength = 15, dom = "tp", language = dt_lang),
              rownames = FALSE)
  })
  
  # ============ МАТЕМАТИКА ============
  output$math_inputs <- renderUI({
    switch(input$math_task,
           "sum" = tagList(
             numericInput("m_a", "Первое число:", value = 0),
             numericInput("m_b", "Второе число:", value = 0)),
           "fact" = numericInput("m_n", "Введите n (0..20):", value = 5, min = 0, max = 20),
           "prime" = numericInput("m_p", "Введите целое число:", value = 17, min = 1),
           "circle" = numericInput("m_r", "Радиус:", value = 5, min = 0),
           "triangle" = tagList(
             numericInput("m_ta", "Сторона a:", value = 3, min = 0),
             numericInput("m_tb", "Сторона b:", value = 4, min = 0),
             numericInput("m_tc", "Сторона c:", value = 5, min = 0)),
           "quad" = tagList(
             numericInput("m_qa", "a:", value = 1),
             numericInput("m_qb", "b:", value = -5),
             numericInput("m_qc", "c:", value = 6))
    )
  })
  
  observeEvent(input$math_calc, {
    res <- switch(input$math_task,
                  "sum" = {
                    a <- input$m_a; b <- input$m_b
                    add_log(paste0("a <- ", a, "; b <- ", b, "; a + b"),
                            paste0("[1] ", a + b), section = "Математика", task = "Сумма")
                    HTML(paste0(
                      "<div class='result-box'>",
                      "<p>Сумма: <span class='result-value'>", a + b, "</span></p>",
                      "<p>Разность: <span class='result-value'>", a - b, "</span></p>",
                      "<p>Произведение: <span class='result-value'>", a * b, "</span></p>",
                      if (b != 0) paste0("<p>Частное: <span class='result-value'>", round(a / b, 4), "</span></p>") else "",
                      "</div>"))
                  },
                  "fact" = {
                    n <- as.integer(input$m_n); r <- factorial(n)
                    add_log(paste0("factorial(", n, ")"), paste0("[1] ", r),
                            section = "Математика", task = "Факториал")
                    HTML(paste0("<div class='result-box'><p>", n, "! = <span class='result-value'>", r, "</span></p></div>"))
                  },
                  "prime" = {
                    n <- as.integer(input$m_p)
                    if (n < 2) { txt <- "Числа меньше 2 не являются простыми" }
                    else if (n == 2) { txt <- paste(n, "— ПРОСТОЕ число") }
                    else {
                      divs <- 2:floor(sqrt(n)); divs <- divs[divs >= 2]
                      is_p <- length(divs) == 0 || all(n %% divs != 0)
                      txt <- if (is_p) paste(n, "— ПРОСТОЕ число") else paste(n, "— составное число")
                    }
                    add_log(paste0("is_prime(", n, ")"), txt, section = "Математика", task = "Простота")
                    HTML(paste0("<div class='result-box'><p>", txt, "</p></div>"))
                  },
                  "circle" = {
                    r <- input$m_r
                    add_log(paste0("pi * ", r, "^2"), paste0("[1] ", round(pi * r^2, 4)),
                            section = "Математика", task = "Круг")
                    HTML(paste0("<div class='result-box'>",
                                "<p>Площадь: <span class='result-value'>", round(pi * r^2, 4), "</span></p>",
                                "<p>Длина окружности: <span class='result-value'>", round(2 * pi * r, 4), "</span></p>",
                                "</div>"))
                  },
                  "triangle" = {
                    a <- input$m_ta; b <- input$m_tb; c <- input$m_tc
                    if (a + b <= c || a + c <= b || b + c <= a) {
                      add_log(paste0("Герон: a=", a, " b=", b, " c=", c),
                              "Ошибка", TRUE, section = "Математика", task = "Треугольник")
                      HTML("<div class='result-box' style='border-left-color:#EF4444;'><p style='color:#F87171;'>Такого треугольника не существует</p></div>")
                    } else {
                      p <- (a + b + c) / 2
                      s <- sqrt(p * (p - a) * (p - b) * (p - c))
                      add_log("sqrt(p*(p-a)*(p-b)*(p-c))", paste0("[1] ", round(s, 4)),
                              section = "Математика", task = "Треугольник")
                      HTML(paste0("<div class='result-box'>",
                                  "<p>Полупериметр: <span class='result-value'>", round(p, 4), "</span></p>",
                                  "<p>Площадь: <span class='result-value'>", round(s, 4), "</span></p>",
                                  "</div>"))
                    }
                  },
                  "quad" = {
                    a <- input$m_qa; b <- input$m_qb; c <- input$m_qc
                    if (a == 0) {
                      add_log(paste0("a=", a), "Ошибка", TRUE, section = "Математика", task = "Квадр.")
                      HTML("<div class='result-box' style='border-left-color:#EF4444;'><p style='color:#F87171;'>При a=0 это не квадратное уравнение</p></div>")
                    } else {
                      D <- b^2 - 4 * a * c
                      add_log(paste0("D <- ", b, "^2 - 4*", a, "*", c), paste0("[1] ", D),
                              section = "Математика", task = "Квадр.")
                      out <- paste0("<div class='result-box'><p>Дискриминант: <span class='result-value'>", D, "</span></p>")
                      if (D > 0) {
                        x1 <- (-b + sqrt(D)) / (2 * a); x2 <- (-b - sqrt(D)) / (2 * a)
                        out <- paste0(out,
                                      "<p>x₁ = <span class='result-value'>", round(x1, 4), "</span></p>",
                                      "<p>x₂ = <span class='result-value'>", round(x2, 4), "</span></p>")
                      } else if (D == 0) {
                        out <- paste0(out, "<p>x = <span class='result-value'>", round(-b/(2*a), 4), "</span></p>")
                      } else {
                        out <- paste0(out, "<p style='color:#F87171;'>Действительных корней нет</p>")
                      }
                      HTML(paste0(out, "</div>"))
                    }
                  }
    )
    output$math_result <- renderUI(res)
  })
  
  # ============ СТАТИСТИКА ============
  output$stats_inputs <- renderUI({
    switch(input$stats_mode,
           "manual" = textAreaInput("s_data", "Введите числа через запятую:",
                                    value = "5, 12, 7, 3, 18, 9, 22, 14, 6, 11", rows = 3),
           "random" = tagList(
             selectInput("s_dist", "Распределение:",
                         choices = c("Нормальное" = "norm",
                                     "Равномерное" = "unif",
                                     "Экспоненциальное" = "exp")),
             numericInput("s_n", "Количество:", value = 100, min = 2),
             conditionalPanel(condition = "input.s_dist == 'norm'",
                              numericInput("s_mu", "Среднее (mu):", value = 10),
                              numericInput("s_sigma", "Ст. отклонение (sigma):", value = 2, min = 0.01)),
             conditionalPanel(condition = "input.s_dist == 'unif'",
                              numericInput("s_a", "Минимум:", value = 0),
                              numericInput("s_b", "Максимум:", value = 100)),
             conditionalPanel(condition = "input.s_dist == 'exp'",
                              numericInput("s_rate", "Интенсивность (rate):", value = 0.5, min = 0.001))
           ),
           "csv" = fileInput("s_file", "Загрузить CSV-файл:",
                             accept = ".csv",
                             buttonLabel = "Обзор...",
                             placeholder = "Файл не выбран"),
           "excel" = fileInput("s_xlsx", "Загрузить Excel-файл:",
                               accept = c(".xlsx", ".xls"),
                               buttonLabel = "Обзор...",
                               placeholder = "Файл не выбран")
    )
  })
  
  stats_data <- eventReactive(input$stats_calc, {
    if (input$stats_mode == "manual") {
      parts <- strsplit(input$s_data, ",")[[1]]
      nums <- suppressWarnings(as.numeric(trimws(parts)))
      nums[!is.na(nums)]
    } else if (input$stats_mode == "random") {
      n <- as.integer(input$s_n)
      if (input$s_dist == "norm") rnorm(n, input$s_mu, input$s_sigma)
      else if (input$s_dist == "unif") runif(n, input$s_a, input$s_b)
      else rexp(n, input$s_rate)
    } else if (input$stats_mode == "csv") {
      req(input$s_file)
      df <- read.csv(input$s_file$datapath)
      num_cols <- names(df)[sapply(df, is.numeric)]
      if (length(num_cols) > 0) df[[num_cols[1]]] else NULL
    } else {
      req(input$s_xlsx)
      df <- readxl::read_excel(input$s_xlsx$datapath)
      num_cols <- names(df)[sapply(df, is.numeric)]
      if (length(num_cols) > 0) df[[num_cols[1]]] else NULL
    }
  })
  
  observeEvent(input$stats_calc, {
    x <- stats_data(); req(length(x) > 0)
    if (input$stats_mode == "manual") {
      code_str <- paste0("x <- c(", trunc_str(input$s_data, 50), ")")
    } else if (input$stats_mode == "random") {
      code_str <- switch(input$s_dist,
                         "norm" = paste0("x <- rnorm(", input$s_n, ", ", input$s_mu, ", ", input$s_sigma, ")"),
                         "unif" = paste0("x <- runif(", input$s_n, ", ", input$s_a, ", ", input$s_b, ")"),
                         "exp"  = paste0("x <- rexp(", input$s_n, ", ", input$s_rate, ")")
      )
    } else if (input$stats_mode == "csv") {
      code_str <- paste0("x <- read.csv('", input$s_file$name, "')")
    } else {
      code_str <- paste0("x <- read_excel('", input$s_xlsx$name, "')")
    }
    add_log(code_str, paste0("Длина: ", length(x), " наблюдений"),
            section = "Статистика", task = "Загрузка")
    add_log("mean(x)", paste0("[1] ", round(mean(x), 4)), section = "Статистика", task = "Среднее")
    add_log("sd(x)", paste0("[1] ", round(sd(x), 4)), section = "Статистика", task = "SD")
  })
  
  output$stats_result <- renderUI({
    x <- stats_data(); req(length(x) > 0)
    HTML(paste0(
      "<div class='result-box'>",
      "<p>Количество наблюдений: <span class='result-value'>", length(x), "</span></p>",
      "<p>Сумма: <span class='result-value'>", round(sum(x), 4), "</span></p>",
      "<p>Среднее: <span class='result-value'>", round(mean(x), 4), "</span></p>",
      "<p>Медиана: <span class='result-value'>", round(median(x), 4), "</span></p>",
      "<p>Минимум / Максимум: <span class='result-value'>", round(min(x), 4), " / ", round(max(x), 4), "</span></p>",
      "<p>Дисперсия: <span class='result-value'>", round(var(x), 4), "</span></p>",
      "<p>Ст. отклонение: <span class='result-value'>", round(sd(x), 4), "</span></p>",
      "<p>Коэф. вариации: <span class='result-value'>", round(sd(x)/mean(x)*100, 2), "%</span></p>",
      "</div>"))
  })
  
  make_plot <- function(light = FALSE) {
    bg <- if (light) "#F1F5F9" else "#0A0A0F"
    fg <- if (light) "#0F172A" else "#E4E4E7"
    muted <- if (light) "#475569" else "#A1A1AA"
    grid_major <- if (light) "#CBD5E1" else "#2A2A3A"
    grid_minor <- if (light) "#E2E8F0" else "#1F1F2A"
    title_color <- if (light) "#4A6CF7" else "#C4B5FD"
    bar_fill <- if (light) "#4A6CF7" else "#8B5CF6"
    bar_border <- if (light) "#FFFFFF" else "#0A0A0F"
    line_color <- if (light) "#06B6D4" else "#22D3EE"
    
    x <- stats_data(); req(length(x) > 0)
    df <- data.frame(x = x)
    ggplot(df, aes(x = x)) +
      geom_histogram(aes(y = after_stat(density)), bins = 20,
                     fill = bar_fill, color = bar_border, alpha = 0.85) +
      geom_density(color = line_color, linewidth = 1.3) +
      labs(title = "Распределение значений", x = "Значения", y = "Плотность") +
      theme_minimal(base_size = 14, base_family = "Inter") +
      theme(
        plot.background = element_rect(fill = bg, color = NA),
        panel.background = element_rect(fill = bg, color = NA),
        panel.grid.major = element_line(color = grid_major, linewidth = 0.4),
        panel.grid.minor = element_line(color = grid_minor, linewidth = 0.2),
        text = element_text(color = fg),
        axis.text = element_text(color = muted),
        axis.title = element_text(color = muted),
        plot.title = element_text(face = "bold", hjust = 0.5,
                                  color = title_color, family = "Space Grotesk")
      )
  }
  
  # ИСПРАВЛЕНО: Убрано bg = if (is_light()) ... из аргументов renderPlot
  output$stats_plot <- renderPlot({
    make_plot(is_light())
  })
  
  output$stats_table <- renderDT({
    x <- stats_data(); req(length(x) > 0)
    datatable(data.frame(`№` = seq_along(x), Значение = round(x, 4)),
              options = list(pageLength = 10, dom = "tp", language = dt_lang),
              rownames = FALSE)
  })
  
  output$dl_plot_png <- downloadHandler(
    filename = function() paste0("plot_", Sys.Date(), ".png"),
    content = function(file) {
      light <- is_light()
      bg <- if (light) "#F1F5F9" else "#0A0A0F"
      ggsave(file, plot = make_plot(light), width = 10, height = 6, dpi = 150, bg = bg)
    }
  )
  output$dl_csv <- downloadHandler(
    filename = function() paste0("data_", Sys.Date(), ".csv"),
    content = function(file) {
      x <- stats_data(); req(length(x) > 0)
      write.csv(data.frame(Значение = x), file, row.names = FALSE)
    }
  )
  output$dl_txt <- downloadHandler(
    filename = function() paste0("console_", Sys.Date(), ".txt"),
    content = function(file) {
      entries <- console_entries()
      lines <- c("=========================================",
                 "  ЛОГ КОНСОЛИ",
                 paste("  Дата:", Sys.Date()),
                 "=========================================", "")
      for (e in entries) {
        lines <- c(lines, paste0("[", e$time, "]"),
                   paste0("> ", e$code), paste0("  ", e$result), "")
      }
      writeLines(lines, file)
    }
  )
  output$dl_pdf <- downloadHandler(
    filename = function() paste0("report_", Sys.Date(), ".pdf"),
    content = function(file) {
      pdf(file, width = 8.27, height = 11.69)
      plot.new()
      text(0.5, 0.85, "ОТЧЁТ АНАЛИЗА ДАННЫХ", cex = 2, font = 2)
      text(0.5, 0.78, paste("Дата:", Sys.Date()), cex = 1.1)
      x <- stats_data()
      if (length(x) > 0) {
        text(0.5, 0.55, "ОПИСАТЕЛЬНАЯ СТАТИСТИКА", cex = 1.3, font = 2)
        stats_lines <- c(
          paste("Количество наблюдений:", length(x)),
          paste("Сумма:", round(sum(x), 4)),
          paste("Среднее:", round(mean(x), 4)),
          paste("Медиана:", round(median(x), 4)),
          paste("Минимум:", round(min(x), 4)),
          paste("Максимум:", round(max(x), 4)),
          paste("Дисперсия:", round(var(x), 4)),
          paste("Ст. отклонение:", round(sd(x), 4)))
        for (i in seq_along(stats_lines)) {
          text(0.5, 0.50 - i*0.03, stats_lines[i], cex = 0.9, adj = 0)
        }
      }
      print(make_plot(is_light()))
      dev.off()
    }
  )
  output$dl_history <- downloadHandler(
    filename = function() paste0("history_", Sys.Date(), ".csv"),
    content = function(file) write.csv(history_entries(), file, row.names = FALSE)
  )
  
  # ============ ФИНАНСЫ ============
  output$fin_inputs <- renderUI({
    switch(input$fin_task,
           "simple" = tagList(
             radioButtons("f_mode", "Режим:",
                          choices = c("Наращение" = "s", "Дисконтирование" = "p"),
                          inline = TRUE),
             numericInput("f_s1", "Сумма:", value = 100000),
             numericInput("f_s2", "Ставка, %:", value = 12),
             numericInput("f_s3", "Срок, лет:", value = 3)),
           "compound" = tagList(
             numericInput("f_c1", "Первоначальная сумма:", value = 100000),
             numericInput("f_c2", "Ставка, %:", value = 12),
             numericInput("f_c3", "Срок, лет:", value = 5),
             numericInput("f_c4", "Капитализаций в год:", value = 12)),
           "pmt" = tagList(
             numericInput("f_p1", "Сумма кредита:", value = 1000000),
             numericInput("f_p2", "Ставка, %:", value = 15),
             numericInput("f_p3", "Срок, лет:", value = 5),
             numericInput("f_p4", "Платежей в год:", value = 12)),
           "fv" = tagList(
             numericInput("f_f1", "Взнос за период:", value = 10000),
             numericInput("f_f2", "Ставка, %:", value = 8),
             numericInput("f_f3", "Срок, лет:", value = 10),
             numericInput("f_f4", "Взносов в год:", value = 12)),
           "npv" = tagList(
             numericInput("f_n1", "Начальные инвестиции:", value = 1000000),
             numericInput("f_n2", "Ставка дисконт., %:", value = 10),
             textInput("f_n3", "Потоки через запятую:", value = "300000, 400000, 500000, 400000")),
           "irr" = tagList(
             numericInput("f_i1", "Начальные инвестиции:", value = 1000000),
             textInput("f_i2", "Потоки через запятую:", value = "300000, 400000, 500000, 400000")),
           "payback" = tagList(
             numericInput("f_pb1", "Начальные инвестиции:", value = 1000000),
             textInput("f_pb2", "Потоки через запятую:", value = "200000, 300000, 400000, 500000")),
           "currency" = tagList(
             numericInput("f_cu1", "Сумма:", value = 100),
             numericInput("f_cu2", "Курс:", value = 90),
             radioButtons("f_cu3", "Направление:",
                          choices = c("Умножить" = "mul", "Разделить" = "div"),
                          inline = TRUE))
    )
  })
  
  observeEvent(input$fin_calc, {
    res <- switch(input$fin_task,
                  "simple" = {
                    if (input$f_mode == "s") {
                      S <- input$f_s1 * (1 + input$f_s2/100 * input$f_s3)
                      add_log(paste0("P*(1+r*n)"), paste0("[1] ", round(S, 2)),
                              section = "Финансы", task = "Простые %")
                      HTML(paste0("<div class='result-box'>",
                                  "<p>Наращённая сумма: <span class='result-value'>", round(S, 2), "</span></p>",
                                  "<p>Проценты: <span class='result-value'>", round(S - input$f_s1, 2), "</span></p>",
                                  "</div>"))
                    } else {
                      P <- input$f_s1 / (1 + input$f_s2/100 * input$f_s3)
                      add_log("S/(1+r*n)", paste0("[1] ", round(P, 2)),
                              section = "Финансы", task = "Дисконт")
                      HTML(paste0("<div class='result-box'>",
                                  "<p>Первоначальная: <span class='result-value'>", round(P, 2), "</span></p>",
                                  "<p>Дисконт: <span class='result-value'>", round(input$f_s1 - P, 2), "</span></p>",
                                  "</div>"))
                    }
                  },
                  "compound" = {
                    r <- input$f_c2/100; n <- input$f_c3; m <- input$f_c4
                    S <- input$f_c1 * (1 + r/m)^(m*n)
                    eff <- (1 + r/m)^m - 1
                    add_log("P*(1+r/m)^(m*n)", paste0("[1] ", round(S, 2)),
                            section = "Финансы", task = "Сложные %")
                    HTML(paste0("<div class='result-box'>",
                                "<p>Наращённая: <span class='result-value'>", round(S, 2), "</span></p>",
                                "<p>Эффективная ставка: <span class='result-value'>", round(eff*100, 4), "%</span></p>",
                                "</div>"))
                  },
                  "pmt" = {
                    r <- input$f_p2/100/input$f_p4; n <- input$f_p3 * input$f_p4
                    pmt <- input$f_p1 * r / (1 - (1 + r)^(-n))
                    total <- pmt * n
                    add_log("P*r/(1-(1+r)^(-n))", paste0("[1] ", round(pmt, 2)),
                            section = "Финансы", task = "Аннуитет")
                    HTML(paste0("<div class='result-box'>",
                                "<p>Платёж: <span class='result-value'>", round(pmt, 2), "</span></p>",
                                "<p>Итого: <span class='result-value'>", round(total, 2), "</span></p>",
                                "<p>Переплата: <span class='result-value'>", round(total - input$f_p1, 2), "</span></p>",
                                "</div>"))
                  },
                  "fv" = {
                    r <- input$f_f2/100/input$f_f4; n <- input$f_f3 * input$f_f4
                    FV <- input$f_f1 * ((1 + r)^n - 1) / r
                    add_log("pmt*((1+r)^n-1)/r", paste0("[1] ", round(FV, 2)),
                            section = "Финансы", task = "FV")
                    HTML(paste0("<div class='result-box'>",
                                "<p>Будущая стоимость: <span class='result-value'>", round(FV, 2), "</span></p>",
                                "<p>Доход: <span class='result-value'>", round(FV - input$f_f1*n, 2), "</span></p>",
                                "</div>"))
                  },
                  "npv" = {
                    cf <- suppressWarnings(as.numeric(trimws(strsplit(input$f_n3, ",")[[1]])))
                    cf <- cf[!is.na(cf)]
                    npv <- -input$f_n1 + sum(cf / (1 + input$f_n2/100)^(1:length(cf)))
                    add_log("-I0 + sum(cf/(1+r)^n)", paste0("[1] ", round(npv, 2)),
                            section = "Финансы", task = "NPV")
                    status <- if (npv > 0) "<p style='color:#22C55E;'>Выгоден</p>"
                    else if (npv < 0) "<p style='color:#EF4444;'>Убыточен</p>"
                    else "<p>На грани</p>"
                    HTML(paste0("<div class='result-box'>",
                                "<p>NPV: <span class='result-value'>", round(npv, 2), "</span></p>",
                                status, "</div>"))
                  },
                  "irr" = {
                    cf <- suppressWarnings(as.numeric(trimws(strsplit(input$f_i2, ",")[[1]])))
                    cf <- cf[!is.na(cf)]
                    npv_at <- function(r) -input$f_i1 + sum(cf / (1 + r)^(1:length(cf)))
                    res <- tryCatch(uniroot(npv_at, c(-0.99, 10))$root, error = function(e) NA)
                    if (is.na(res)) {
                      add_log("uniroot()", "Не найдено", TRUE, section = "Финансы", task = "IRR")
                      HTML("<div class='result-box'><p>Не удалось найти IRR</p></div>")
                    } else {
                      add_log("uniroot(npv_at)", paste0("[1] ", round(res*100, 4), "%"),
                              section = "Финансы", task = "IRR")
                      HTML(paste0("<div class='result-box'>",
                                  "<p>IRR: <span class='result-value'>", round(res*100, 4), "%</span></p>",
                                  "</div>"))
                    }
                  },
                  "payback" = {
                    cf <- suppressWarnings(as.numeric(trimws(strsplit(input$f_pb2, ",")[[1]])))
                    cf <- cf[!is.na(cf)]
                    cum <- cumsum(cf); idx <- which(cum >= input$f_pb1)
                    if (length(idx) == 0) {
                      add_log("cumsum(cf)", "Не окупается", section = "Финансы", task = "Payback")
                      HTML("<div class='result-box'><p>Не окупается</p></div>")
                    } else {
                      k <- idx[1]; prev <- if (k == 1) 0 else cum[k-1]
                      pb <- (k - 1) + (input$f_pb1 - prev) / cf[k]
                      add_log("cumsum(cf)", paste0("PB = ", round(pb, 2), " лет"),
                              section = "Финансы", task = "Payback")
                      HTML(paste0("<div class='result-box'>",
                                  "<p>Срок окупаемости: <span class='result-value'>", round(pb, 2), " лет</span></p>",
                                  "</div>"))
                    }
                  },
                  "currency" = {
                    res <- if (input$f_cu3 == "mul") input$f_cu1 * input$f_cu2
                    else input$f_cu1 / input$f_cu2
                    add_log("конвертация", paste0("[1] ", round(res, 4)),
                            section = "Финансы", task = "Валюта")
                    HTML(paste0("<div class='result-box'>",
                                "<p>Результат: <span class='result-value'>", round(res, 4), "</span></p>",
                                "</div>"))
                  }
    )
    output$fin_result <- renderUI(res)
  })
}

shinyApp(ui = ui, server = server)