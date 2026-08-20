-- Strips org tag markers from headers, and (when the `trim` metadata
-- variable is set) drops any subtree headed by a :pdfskip: tagged header.
-- Used to keep a full-history cv.org as the single source, while the PDF
-- build gets a shorter version and the HTML build keeps everything.

local trim = false

function Meta(m)
  if m.trim then
    trim = true
  end
end

local function has_tag(header, tagname)
  for _, inline in ipairs(header.content) do
    if inline.t == "Span" and inline.classes:includes("tag") then
      if inline.attributes["tag-name"] == tagname then
        return true
      end
    end
  end
  return false
end

local function strip_tag_spans(header)
  local new_content = {}
  for _, inline in ipairs(header.content) do
    if inline.t == "Span" and inline.classes:includes("tag") then
      if #new_content > 0 and new_content[#new_content].t == "Space" then
        table.remove(new_content)
      end
    else
      table.insert(new_content, inline)
    end
  end
  header.content = new_content
  return header
end

function Pandoc(doc)
  local out = {}
  local skipping = false
  local skip_level = nil

  for _, block in ipairs(doc.blocks) do
    if block.t == "Header" then
      if skipping and block.level <= skip_level then
        skipping = false
      end
      local is_skip = has_tag(block, "pdfskip")
      block = strip_tag_spans(block)
      if is_skip and trim then
        skipping = true
        skip_level = block.level
      elseif not skipping then
        table.insert(out, block)
      end
    elseif not skipping then
      table.insert(out, block)
    end
  end

  doc.blocks = out
  return doc
end
