// shin colors for the browser frame, menus and panels (the shapes and font are in
// ../../chrome/userChrome.css). Same palette as helix's shin theme.
const bg = "#000000", bgAlt = "#1e1e1e", surface = "#2a2a2a", line = "#393939";
const fg = "#e9e9e9", fgDim = "#cfcfcf", muted = "#989898";
const wine = "#8c1625", wineBright = "#cb4d66", wineDeep = "#750017";

browser.theme.update({
  colors: {
    frame: bg,
    frame_inactive: bg,
    tab_background_text: muted,
    tab_selected: wine,
    tab_text: fg,
    tab_line: wine,
    tab_loading: wineBright,
    toolbar: bg,
    toolbar_text: fg,
    toolbar_top_separator: bg,
    toolbar_bottom_separator: wine,
    toolbar_vertical_separator: line,
    toolbar_field: bgAlt,
    toolbar_field_text: fg,
    toolbar_field_border: bgAlt,
    toolbar_field_focus: bg,
    toolbar_field_text_focus: fg,
    toolbar_field_border_focus: wine,
    toolbar_field_highlight: wineDeep,
    toolbar_field_highlight_text: fg,
    button_background_hover: bgAlt,
    button_background_active: surface,
    icons: fgDim,
    icons_attention: wineBright,
    bookmark_text: fgDim,
    popup: bg,
    popup_text: fg,
    popup_border: wine,
    popup_highlight: wine,
    popup_highlight_text: fg,
    sidebar: bg,
    sidebar_text: fg,
    sidebar_border: line,
    sidebar_highlight: wine,
    sidebar_highlight_text: fg,
    ntp_background: bg,
    ntp_text: fg,
  },
  properties: {
    color_scheme: "dark",
    content_color_scheme: "dark",
  },
});
