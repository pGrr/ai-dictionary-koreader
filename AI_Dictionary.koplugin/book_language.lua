-- book_language.lua
-- Detects the language of the currently open book and provides
-- language-specific strings for AI prompts and UI during AI interaction.
-- Also provides translations for plugin menu strings based on KOReader's UI language.
-- Falls back to English when language is unknown.

local BookLanguage = {}

-- ISO 639-1 code -> English language name
local LANGUAGE_NAMES = {
    af = "Afrikaans", ar = "Arabic", bg = "Bulgarian", ca = "Catalan",
    cs = "Czech", cy = "Welsh", da = "Danish", de = "German",
    el = "Greek", en = "English", es = "Spanish", et = "Estonian",
    eu = "Basque", fa = "Persian", fi = "Finnish", fr = "French",
    ga = "Irish", gl = "Galician", he = "Hebrew", hi = "Hindi",
    hr = "Croatian", hu = "Hungarian", id = "Indonesian", is = "Icelandic",
    it = "Italian", ja = "Japanese", ko = "Korean", la = "Latin",
    lt = "Lithuanian", lv = "Latvian", mk = "Macedonian", ms = "Malay",
    nb = "Norwegian Bokmål", nl = "Dutch", nn = "Norwegian Nynorsk",
    no = "Norwegian", pl = "Polish", pt = "Portuguese", ro = "Romanian",
    ru = "Russian", sk = "Slovak", sl = "Slovenian", sq = "Albanian",
    sr = "Serbian", sv = "Swedish", th = "Thai", tr = "Turkish",
    uk = "Ukrainian", vi = "Vietnamese", zh = "Chinese",
}

-- Dictionary section labels per language.
-- Order: Definition, Example, Synonyms, Paraphrase, Etymology
local DICTIONARY_LABELS = {
    en = { "Definition", "Example", "Synonyms", "Paraphrase", "Etymology" },
    it = { "Definizione", "Esempio", "Sinonimi", "Parafrasi", "Etimologia" },
    fr = { "Définition", "Exemple", "Synonymes", "Paraphrase", "Étymologie" },
    de = { "Definition", "Beispiel", "Synonyme", "Umschreibung", "Etymologie" },
    es = { "Definición", "Ejemplo", "Sinónimos", "Paráfrasis", "Etimología" },
    pt = { "Definição", "Exemplo", "Sinônimos", "Paráfrase", "Etimologia" },
    nl = { "Definitie", "Voorbeeld", "Synoniemen", "Parafrase", "Etymologie" },
    ru = { "Определение", "Пример", "Синонимы", "Перефразировка", "Этимология" },
    pl = { "Definicja", "Przykład", "Synonimy", "Parafraza", "Etymologia" },
    ja = { "定義", "例文", "類義語", "言い換え", "語源" },
    zh = { "定义", "例句", "同义词", "释义", "词源" },
    ko = { "정의", "예문", "동의어", "바꿔 말하기", "어원" },
    sv = { "Definition", "Exempel", "Synonymer", "Omskrivning", "Etymologi" },
    da = { "Definition", "Eksempel", "Synonymer", "Omskrivning", "Etymologi" },
    no = { "Definisjon", "Eksempel", "Synonymer", "Omskriving", "Etymologi" },
    fi = { "Määritelmä", "Esimerkki", "Synonyymit", "Selitys", "Etymologia" },
    cs = { "Definice", "Příklad", "Synonyma", "Parafráze", "Etymologie" },
    ro = { "Definiție", "Exemplu", "Sinonime", "Parafrază", "Etimologie" },
    hu = { "Meghatározás", "Példa", "Szinonimák", "Körülírás", "Szóeredet" },
    tr = { "Tanım", "Örnek", "Eş anlamlılar", "Açıklama", "Köken" },
    el = { "Ορισμός", "Παράδειγμα", "Συνώνυμα", "Παράφραση", "Ετυμολογία" },
    uk = { "Визначення", "Приклад", "Синоніми", "Перефразування", "Етимологія" },
    ar = { "التعريف", "مثال", "مرادفات", "إعادة صياغة", "أصل الكلمة" },
    he = { "הגדרה", "דוגמה", "מילים נרדפות", "ניסוח מחדש", "אטימולוגיה" },
    hi = { "परिभाषा", "उदाहरण", "पर्यायवाची", "भावार्थ", "व्युत्पत्ति" },
    la = { "Definitio", "Exemplum", "Synonyma", "Paraphrasis", "Etymologia" },
}

-- UI strings shown during AI interaction (not system menus).
local UI_STRINGS = {
    en = {
        offline_wait = "You are offline. AI lookup requires an active internet connection.",
        online_wait = "Getting the answer...",
        generating_report = "Generating report...",
        word_copied = "Word copied to clipboard.",
        selection_copied = "Selection copied to clipboard.",
        stream_stalled = "Streaming stalled; retrying without streaming...",
        error_querying = "Error querying AI: ",
    },
    it = {
        offline_wait = "Sei offline. La consultazione AI richiede una connessione internet attiva.",
        online_wait = "Sto cercando la risposta...",
        generating_report = "Generazione del report in corso...",
        word_copied = "Parola copiata negli appunti.",
        selection_copied = "Selezione copiata negli appunti.",
        stream_stalled = "Streaming interrotto; nuovo tentativo senza streaming...",
        error_querying = "Errore nella query AI: ",
    },
    fr = {
        offline_wait = "Vous êtes hors ligne. La recherche IA nécessite une connexion internet active.",
        online_wait = "Recherche de la réponse...",
        generating_report = "Génération du rapport...",
        word_copied = "Mot copié dans le presse-papiers.",
        selection_copied = "Sélection copiée dans le presse-papiers.",
        stream_stalled = "Flux interrompu ; nouvel essai sans streaming...",
        error_querying = "Erreur lors de la requête IA : ",
    },
    de = {
        offline_wait = "Sie sind offline. Die KI-Suche erfordert eine aktive Internetverbindung.",
        online_wait = "Antwort wird gesucht...",
        generating_report = "Bericht wird erstellt...",
        word_copied = "Wort in die Zwischenablage kopiert.",
        selection_copied = "Auswahl in die Zwischenablage kopiert.",
        stream_stalled = "Streaming unterbrochen; erneuter Versuch ohne Streaming...",
        error_querying = "Fehler bei der KI-Abfrage: ",
    },
    es = {
        offline_wait = "Estás sin conexión. La búsqueda IA requiere una conexión a internet activa.",
        online_wait = "Buscando la respuesta...",
        generating_report = "Generando el informe...",
        word_copied = "Palabra copiada al portapapeles.",
        selection_copied = "Selección copiada al portapapeles.",
        stream_stalled = "Streaming interrumpido; reintentando sin streaming...",
        error_querying = "Error en la consulta IA: ",
    },
    pt = {
        offline_wait = "Você está offline. A consulta IA requer uma conexão de internet ativa.",
        online_wait = "Buscando a resposta...",
        generating_report = "Gerando o relatório...",
        word_copied = "Palavra copiada para a área de transferência.",
        selection_copied = "Seleção copiada para a área de transferência.",
        stream_stalled = "Streaming interrompido; tentando novamente sem streaming...",
        error_querying = "Erro na consulta IA: ",
    },
    nl = {
        offline_wait = "Je bent offline. AI-zoeken vereist een actieve internetverbinding.",
        online_wait = "Antwoord zoeken...",
        generating_report = "Rapport genereren...",
        word_copied = "Woord gekopieerd naar klembord.",
        selection_copied = "Selectie gekopieerd naar klembord.",
        stream_stalled = "Streaming onderbroken; opnieuw proberen zonder streaming...",
        error_querying = "Fout bij AI-query: ",
    },
    ru = {
        offline_wait = "Вы не в сети. Для поиска через ИИ требуется активное подключение к интернету.",
        online_wait = "Ищу ответ...",
        generating_report = "Генерация отчёта...",
        word_copied = "Слово скопировано в буфер обмена.",
        selection_copied = "Выделение скопировано в буфер обмена.",
        stream_stalled = "Потоковая передача прервана; повторная попытка без потоковой передачи...",
        error_querying = "Ошибка запроса к ИИ: ",
    },
    pl = {
        offline_wait = "Jesteś offline. Wyszukiwanie AI wymaga aktywnego połączenia z internetem.",
        online_wait = "Szukam odpowiedzi...",
        generating_report = "Generowanie raportu...",
        word_copied = "Słowo skopiowane do schowka.",
        selection_copied = "Zaznaczenie skopiowane do schowka.",
        stream_stalled = "Streaming przerwany; ponowna próba bez streamingu...",
        error_querying = "Błąd zapytania AI: ",
    },
    ja = {
        offline_wait = "オフラインです。AI検索にはインターネット接続が必要です。",
        online_wait = "回答を検索中...",
        generating_report = "レポートを生成中...",
        word_copied = "単語をクリップボードにコピーしました。",
        selection_copied = "選択範囲をクリップボードにコピーしました。",
        stream_stalled = "ストリーミングが停止しました。ストリーミングなしで再試行中...",
        error_querying = "AIクエリエラー：",
    },
    zh = {
        offline_wait = "您处于离线状态。AI查询需要网络连接。",
        online_wait = "正在获取答案...",
        generating_report = "正在生成报告...",
        word_copied = "已复制单词到剪贴板。",
        selection_copied = "已复制选区到剪贴板。",
        stream_stalled = "流式传输停滞；正在以非流式方式重试...",
        error_querying = "AI查询错误：",
    },
    ko = {
        offline_wait = "오프라인 상태입니다. AI 검색에는 인터넷 연결이 필요합니다.",
        online_wait = "답변을 검색 중...",
        generating_report = "보고서 생성 중...",
        word_copied = "단어가 클립보드에 복사되었습니다.",
        selection_copied = "선택 영역이 클립보드에 복사되었습니다.",
        stream_stalled = "스트리밍이 중단되었습니다. 스트리밍 없이 재시도 중...",
        error_querying = "AI 쿼리 오류: ",
    },
}

-- Plugin-specific UI string translations, keyed by KOReader's UI language.
-- These are strings that KOReader's gettext doesn't know about.
local PLUGIN_TRANSLATIONS = {
    it = {
        ["AI Explain"] = "Spiegazione AI",
        ["AI Simplify"] = "Semplificazione AI",
        ["AI Dictionary"] = "Dizionario AI",
        ["AI Dictionary Lookups Report"] = "Report ricerche Dizionario AI",
        ["AI Dictionary settings"] = "Impostazioni Dizionario AI",
        ["Generate Report"] = "Genera report",
        ["Timeframe"] = "Periodo",
        ["Delete custom setting"] = "Elimina impostazione personalizzata",
        ["Add setting"] = "Aggiungi impostazione",
        ["No lookups found for "] = "Nessuna ricerca trovata per ",
        ["AI Dictionary settings saved."] = "Impostazioni Dizionario AI salvate.",
        ["Could not save configuration.lua:"] = "Impossibile salvare configuration.lua:",
        ["not set"] = "non impostato",
        ["set"] = "impostato",
        ["Edit"] = "Modifica",
        ["Set"] = "Imposta",
        ["Enter a Lua literal: string, number, boolean, or table."] = "Inserisci un valore Lua: stringa, numero, booleano o tabella.",
        ["Enter a Lua identifier, for example: additional_parameters"] = "Inserisci un identificatore Lua, ad esempio: additional_parameters",
        ["Please enter a valid number."] = "Inserisci un numero valido.",
        ["Please enter a valid non-nil Lua value."] = "Inserisci un valore Lua valido e non-nil.",
        ["Setting names must be Lua identifiers."] = "I nomi delle impostazioni devono essere identificatori Lua.",
        ["That setting already exists."] = "Questa impostazione esiste già.",
    },
    fr = {
        ["AI Explain"] = "Explication IA",
        ["AI Simplify"] = "Simplification IA",
        ["AI Dictionary"] = "Dictionnaire IA",
        ["AI Dictionary Lookups Report"] = "Rapport de recherches Dictionnaire IA",
        ["AI Dictionary settings"] = "Paramètres Dictionnaire IA",
        ["Generate Report"] = "Générer le rapport",
        ["Timeframe"] = "Période",
        ["Delete custom setting"] = "Supprimer le paramètre personnalisé",
        ["Add setting"] = "Ajouter un paramètre",
        ["No lookups found for "] = "Aucune recherche trouvée pour ",
        ["AI Dictionary settings saved."] = "Paramètres Dictionnaire IA enregistrés.",
        ["not set"] = "non défini",
        ["set"] = "défini",
        ["Edit"] = "Modifier",
        ["Set"] = "Définir",
    },
    de = {
        ["AI Explain"] = "KI-Erklärung",
        ["AI Simplify"] = "KI-Vereinfachung",
        ["AI Dictionary"] = "KI-Wörterbuch",
        ["AI Dictionary Lookups Report"] = "KI-Wörterbuch Nachschlagebericht",
        ["AI Dictionary settings"] = "KI-Wörterbuch Einstellungen",
        ["Generate Report"] = "Bericht erstellen",
        ["Timeframe"] = "Zeitraum",
        ["Delete custom setting"] = "Einstellung löschen",
        ["Add setting"] = "Einstellung hinzufügen",
        ["No lookups found for "] = "Keine Einträge gefunden für ",
        ["AI Dictionary settings saved."] = "KI-Wörterbuch Einstellungen gespeichert.",
        ["not set"] = "nicht gesetzt",
        ["set"] = "gesetzt",
        ["Edit"] = "Bearbeiten",
        ["Set"] = "Setzen",
    },
    es = {
        ["AI Explain"] = "Explicación IA",
        ["AI Simplify"] = "Simplificación IA",
        ["AI Dictionary"] = "Diccionario IA",
        ["AI Dictionary Lookups Report"] = "Informe de búsquedas Diccionario IA",
        ["AI Dictionary settings"] = "Configuración Diccionario IA",
        ["Generate Report"] = "Generar informe",
        ["Timeframe"] = "Período",
        ["Delete custom setting"] = "Eliminar configuración personalizada",
        ["Add setting"] = "Agregar configuración",
        ["No lookups found for "] = "No se encontraron búsquedas para ",
        ["AI Dictionary settings saved."] = "Configuración Diccionario IA guardada.",
        ["not set"] = "no definido",
        ["set"] = "definido",
        ["Edit"] = "Editar",
        ["Set"] = "Definir",
    },
    pt = {
        ["AI Explain"] = "Explicação IA",
        ["AI Simplify"] = "Simplificação IA",
        ["AI Dictionary"] = "Dicionário IA",
        ["AI Dictionary Lookups Report"] = "Relatório de pesquisas Dicionário IA",
        ["AI Dictionary settings"] = "Configurações Dicionário IA",
        ["Generate Report"] = "Gerar relatório",
        ["Timeframe"] = "Período",
        ["Delete custom setting"] = "Excluir configuração personalizada",
        ["Add setting"] = "Adicionar configuração",
        ["No lookups found for "] = "Nenhuma pesquisa encontrada para ",
        ["AI Dictionary settings saved."] = "Configurações Dicionário IA salvas.",
        ["not set"] = "não definido",
        ["set"] = "definido",
        ["Edit"] = "Editar",
        ["Set"] = "Definir",
    },
    ru = {
        ["AI Explain"] = "ИИ объяснение",
        ["AI Simplify"] = "ИИ упрощение",
        ["AI Dictionary"] = "ИИ словарь",
        ["AI Dictionary Lookups Report"] = "Отчёт запросов ИИ словаря",
        ["AI Dictionary settings"] = "Настройки ИИ словаря",
        ["Generate Report"] = "Создать отчёт",
        ["Timeframe"] = "Период",
        ["Delete custom setting"] = "Удалить настройку",
        ["not set"] = "не задано",
        ["set"] = "задано",
    },
    pl = {
        ["AI Explain"] = "Wyjaśnienie AI",
        ["AI Simplify"] = "Uproszczenie AI",
        ["AI Dictionary"] = "Słownik AI",
    },
    nl = {
        ["AI Explain"] = "AI-uitleg",
        ["AI Simplify"] = "AI-vereenvoudiging",
        ["AI Dictionary"] = "AI-woordenboek",
    },
    ja = {
        ["AI Explain"] = "AI 説明",
        ["AI Simplify"] = "AI 簡略化",
        ["AI Dictionary"] = "AI 辞書",
    },
    zh = {
        ["AI Explain"] = "AI 解释",
        ["AI Simplify"] = "AI 简化",
        ["AI Dictionary"] = "AI 词典",
    },
    ko = {
        ["AI Explain"] = "AI 설명",
        ["AI Simplify"] = "AI 간소화",
        ["AI Dictionary"] = "AI 사전",
    },
}

--- Extract a two-letter language code from a locale string.
-- Handles formats like "it", "it_IT", "it_IT.UTF-8", etc.
-- Returns nil for empty, "C", "POSIX", or English-only locales.
-- @param s Locale string
-- @return Two-letter language code or nil
local function extract_lang_code(s)
    if type(s) ~= "string" or s == "" then return nil end
    local lower = s:lower()
    if lower == "c" or lower == "posix" then return nil end
    local code = lower:match("^([a-z][a-z])")
    if not code or code == "en" then return nil end
    return code
end

--- Detect the language of KOReader's user interface.
-- Tries multiple detection methods in order of reliability.
-- Returns a two-letter ISO 639-1 code (e.g. "it") or nil for English/unknown.
-- @return Language code or nil
function BookLanguage.get_koreader_language()
    -- Method 1: G_reader_settings (most reliable — this is the user's
    -- explicit language choice, persisted across restarts)
    if type(G_reader_settings) ~= "nil" then
        local ok, lang = pcall(function()
            if G_reader_settings.readSetting then
                return G_reader_settings:readSetting("language")
            end
        end)
        if ok then
            local code = extract_lang_code(lang)
            if code then return code end
        end
    end

    -- Method 2: gettext module internals
    local gok, gettext = pcall(require, "gettext")
    if gok then
        -- gettext is a table with __call metamethod in KOReader
        local clang = nil
        if type(gettext) == "table" then
            clang = gettext.current_lang or gettext.locale
        end
        local code = extract_lang_code(clang)
        if code then return code end
    end

    -- Method 3: environment variables (last resort)
    local env_lang = os.getenv("LC_ALL") or os.getenv("LC_MESSAGES")
                  or os.getenv("LANGUAGE") or os.getenv("LANG")
    local code = extract_lang_code(env_lang)
    if code then return code end

    return nil
end

--- Translate a plugin-specific UI string to KOReader's UI language.
-- First tries KOReader's gettext _(), then falls back to the plugin's
-- own translation table. Returns the original text if no translation found.
-- @param text The English text to translate
-- @return Translated text
function BookLanguage.translate_ui(text)
    local gettext_ok, gettext = pcall(function() return require("gettext") end)
    if gettext_ok and gettext then
        local translated = gettext(text)
        if translated ~= text then
            return translated
        end
    end
    local lang = BookLanguage.get_koreader_language()
    if lang and PLUGIN_TRANSLATIONS[lang] then
        return PLUGIN_TRANSLATIONS[lang][text] or text
    end
    return text
end

--- Escape a string for safe use in a Lua pattern.
-- @param s The string to escape
-- @return Pattern-safe string
function BookLanguage.escape_pattern(s)
    return (s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

--- Escape a string for safe use as a gsub replacement value.
-- In Lua gsub replacements, % is special (backreferences).
-- @param s The string to escape
-- @return Replacement-safe string
function BookLanguage.escape_replacement(s)
    return (s:gsub("%%", "%%%%"))
end

--- Detect the language of the currently open book.
-- @param ui The KOReader UI object (self.ui from a plugin)
-- @return Language code (e.g. "it", "en") or nil if unavailable
function BookLanguage.detect(ui)
    if not (ui and ui.document and ui.document.getProps) then
        return nil
    end
    local ok, props = pcall(function() return ui.document:getProps() end)
    if not ok or not props then
        return nil
    end
    local lang = props.language
    if type(lang) ~= "string" or lang == "" then
        return nil
    end
    -- Normalize: "en-US" -> "en", "pt-BR" -> "pt", etc.
    lang = lang:lower():match("^([a-z]+)")
    return lang
end

--- Get the full English name for a language code.
-- @param lang_code ISO 639-1 language code, or nil
-- @return Language name string (e.g. "Italian"), defaults to "English"
function BookLanguage.get_name(lang_code)
    if not lang_code then
        return "English"
    end
    return LANGUAGE_NAMES[lang_code] or lang_code
end

--- Get translated dictionary section labels for a language.
-- @param lang_code ISO 639-1 language code, or nil
-- @return Table of 5 labels: {Definition, Example, Synonyms, Paraphrase, Etymology}
function BookLanguage.get_dictionary_labels(lang_code)
    if not lang_code then
        return DICTIONARY_LABELS.en
    end
    return DICTIONARY_LABELS[lang_code] or DICTIONARY_LABELS.en
end

--- Get a localized UI string for the AI interaction context.
-- @param lang_code ISO 639-1 language code, or nil
-- @param key String key (e.g. "online_wait", "word_copied")
-- @return Localized string, falls back to English
function BookLanguage.get_ui_string(lang_code, key)
    local strings = lang_code and UI_STRINGS[lang_code]
    if strings and strings[key] then
        return strings[key]
    end
    return UI_STRINGS.en[key] or ""
end

--- Get the pronunciation language label for the AI Dictionary prompt.
-- @param lang_code ISO 639-1 language code, or nil
-- @return Pronunciation language string (e.g. "American (US) English", "Italian")
function BookLanguage.get_pronunciation_language(lang_code)
    if not lang_code or lang_code == "en" then
        return "American (US) English"
    end
    return BookLanguage.get_name(lang_code)
end

--- Get the AI language instruction to append to prompts.
-- Returns empty string for English (no instruction needed).
-- @param lang_code ISO 639-1 language code, or nil
-- @return Instruction string (e.g. " Answer entirely in Italian.")
function BookLanguage.get_ai_language_instruction(lang_code)
    if not lang_code or lang_code == "en" then
        return ""
    end
    local name = BookLanguage.get_name(lang_code)
    return " Answer entirely in " .. name .. "."
end

return BookLanguage
