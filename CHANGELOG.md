# Changelog

## Multilingual Support (2026-06-26)

**Commit**: `33b1bc9` — *Added multilingual support – adapts to the current book's language for outputs and KOReader user's language for settings*

This release introduces comprehensive multilingual support, making AI Dictionary a truly language-agnostic tool. The plugin now automatically adapts to the language of the book you are reading and to the language of your KOReader interface, without any manual configuration.

---

### New Features

#### 🌍 Automatic Book Language Detection

The plugin reads the book's metadata to determine its language (e.g. Italian, French, German…) and uses it to shape all AI interactions:

- **AI responses in the book's language**: definitions, explanations, and simplified text are generated in the same language as the book.
- **Translated dictionary labels**: the sections of a dictionary entry (Definition, Example, Synonyms, Paraphrase, Etymology) are rendered in the book's language, with built-in translations for **25+ languages**.
- **Language-aware pronunciation**: the IPA pronunciation field in dictionary entries adapts to the book's language (e.g. "Italian" instead of the previous hard-coded "American (US) English").
- **Language-specific AI instructions**: each prompt is appended with an explicit instruction to the AI (e.g. *"Answer entirely in Italian."*) to ensure the response is in the correct language.

#### 🖥️ Localized User Interface

UI messages shown during AI interactions (loading indicators, clipboard notifications, error messages) are translated into the book's language for **12 languages**: English, Italian, French, German, Spanish, Portuguese, Dutch, Russian, Polish, Japanese, Chinese, Korean.

#### ⚙️ Localized Settings and System Menus

Plugin settings, report dialogs, and the updater now follow KOReader's own interface language:

- Menu items like "AI Dictionary settings", "AI Dictionary Lookups Report", "Generate Report", "Timeframe", etc. are translated via a dual-layer mechanism:
  1. KOReader's built-in `gettext` translations are tried first.
  2. The plugin's own translation table is used as a fallback.
- The updater dialogs ("Update now?", "AI Dictionary was updated.", "Quit", etc.) are also localized.

#### 🗣️ Renamed "AI English Simplify" → "AI Simplify"

The "AI English Simplify" action has been renamed to **"AI Simplify"**. The prompt no longer assumes English: it dynamically uses the book's language name (e.g. *"Explain its meaning in simple, understandable Italian"*).

---

### Technical Details

#### New Module: `book_language.lua`

A dedicated new module (`AI_Dictionary.koplugin/book_language.lua`, **466 lines**) encapsulates all language-related logic:

| Function | Purpose |
|---|---|
| `detect(ui)` | Extracts the book's language from document metadata |
| `get_name(lang_code)` | Returns the full English name for a language code (e.g. `"it"` → `"Italian"`) |
| `get_dictionary_labels(lang_code)` | Returns translated dictionary section labels (Definition, Example, …) |
| `get_ui_string(lang_code, key)` | Returns a localized UI string (e.g. loading messages, clipboard notifications) |
| `get_pronunciation_language(lang_code)` | Returns the pronunciation language label for dictionary prompts |
| `get_ai_language_instruction(lang_code)` | Returns the language instruction to append to AI prompts |
| `translate_ui(text)` | Translates plugin-specific UI strings to KOReader's interface language |
| `get_koreader_language()` | Detects KOReader's UI language via settings, gettext, or env variables |
| `escape_pattern(s)` / `escape_replacement(s)` | Safely escapes strings for use in Lua patterns |

The module contains:
- A **language names table** mapping ISO 639-1 codes to full English names.
- **Dictionary section labels** translated into 25+ languages.
- **UI strings** translated into 12 languages.
- **Plugin-specific translations** for menu items and dialogs.

#### Graceful Degradation

All language features are wrapped in safe fallback mechanisms:

- If `book_language.lua` fails to load, the plugin falls back to its original English-only behavior.
- A diagnostic message is shown on startup if the module fails to load.
- The `format_dictionary_output` function is wrapped in `pcall` to prevent crashes from unexpected label formats.
- The `find_dictionary_section_boundary` function uses pattern-escaped labels to avoid Lua pattern errors with special characters in translated labels.

#### Dynamic Prompt Templates

The AI prompt templates now use placeholder variables that are resolved at query time:

| Placeholder | Resolved To |
|---|---|
| `{language_name}` | Full language name (e.g. "Italian") |
| `{language_instruction}` | AI instruction (e.g. " Answer entirely in Italian.") |
| `{pronunciation_language}` | Pronunciation language (e.g. "Italian") |
| `{definition_label}` | Translated "Definition" label |
| `{example_label}` | Translated "Example" label |
| `{synonyms_label}` | Translated "Synonyms" label |
| `{paraphrase_label}` | Translated "Paraphrase" label |
| `{etymology_label}` | Translated "Etymology" label |

#### Viewer Language Propagation

The `lang_code` is propagated through the viewer chain (`ChatGPTViewer`) so that even clipboard notifications within the viewer respect the book's language.

---

### Files Changed

| File | Change |
|---|---|
| `AI_Dictionary.koplugin/book_language.lua` | **New file** — multilingual support module |
| `AI_Dictionary.koplugin/main.lua` | Language detection integration, translated prompts, localized UI, safe fallbacks |
| `AI_Dictionary.koplugin/chatgptviewer.lua` | Propagates `lang_code`, localized clipboard notifications |
| `AI_Dictionary.koplugin/updater.lua` | Localized update dialogs and messages |
| `README.md` | Updated to reflect multilingual support, renamed action, removed "English-only" roadmap item |
