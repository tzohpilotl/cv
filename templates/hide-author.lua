-- Keep author in document metadata (HTML <meta>, PDF pdfauthor) but
-- suppress the visible byline under the title, since the title already
-- states the author's name.
function Meta(meta)
  if meta.author then
    meta["author-meta"] = pandoc.utils.stringify(meta.author)
    meta.author = nil
  end
  return meta
end
