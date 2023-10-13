-- hdlr alternatively, use lua vim.lsp.diagnostic.set_loclist({open_loclist = false})
-- true to open loclist
-- local diag_hdlr = function(err, method, result, client_id, bufnr, config)
-- New signature on_publish_diagnostics({_}, {result}, {ctx}, {config})
debug = debug or nil
local vfn = vim.fn
local function hdlr(result)
  if result and result.diagnostics then
    local item_list = {}
    local s = result.uri
    local fname = s
    for _, v in ipairs(result.diagnostics) do
      local _, j = string.find(s, 'file://')
      if j then
        fname = string.sub(s, j + 1)
      end
      table.insert(item_list, {
        filename = fname,
        lnum = v.range.start.line + 1,
        col = v.range.start.character + 1,
        text = v.message,
      })
    end
    local old_items = vfn.getqflist()
    for _, old_item in ipairs(old_items) do
      if vim.uri_from_bufnr(old_item.bufnr) ~= result.uri then
        table.insert(item_list, old_item)
      end
    end
    vfn.setqflist({}, ' ', { title = 'LSP', items = item_list })
  end
end

return {
  setup = function()
    local _diag_hdlr
    if _GO_NVIM_CFG.diagnostic.hdlr == true then
      _diag_hdlr = function(err, result, ctx, config)
        vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
        hdlr(result)
      end
    else
      diag_hdlr = vim.lsp.diagnostic.on_publish_diagnostics
    end
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(diag_hdlr, {
      underline = _GO_NVIM_CFG.diagnostic.underline,
      virtual_text = _GO_NVIM_CFG.diagnostic.virtual_text,
      signs = _GO_NVIM_CFG.diagnostic.signs,
      update_in_insert = _GO_NVIM_CFG.diagnostic.update_in_insert,
    })
  end,
  handler = diag_hdlr,
}
