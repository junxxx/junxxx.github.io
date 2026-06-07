---
title: "Hugo Shortcodes: A Practical Guide"
date: 2026-06-07T11:00:00+08:00
draft: false
categories: ["Tech", "Hugo"]
tags: ["Hugo", "Shortcodes", "Static Site"]
author: "Paisen"
---

Hugo shortcodes are simple snippets inside your content files that call built-in or custom templates. They are a powerful way to inject dynamic content into your Markdown without writing raw HTML.

## Why Shortcodes?

Markdown is great for writing, but it falls short when you need to embed complex elements like videos, tweets, or custom layouts. Shortcodes bridge the gap — they keep your content clean while giving you the full power of Hugo templates.

## Built-in Shortcodes

Hugo ships with several useful shortcodes out of the box.

### Figure

```markdown
{{</* figure src="/images/example.png" title="An example image" caption="This is a caption" alt="example" */>}}
```

This generates semantic HTML with `<figure>`, `<img>`, and `<figcaption>` tags.

### YouTube

```markdown
{{</* youtube dQw4w9WgXcQ */>}}
```

Embeds a responsive YouTube iframe. You can also pass `autoplay=1` as a second parameter.

### Tweet

```markdown
{{</* tweet 123456789 */>}}
```

Embeds a Twitter/X card with a single tweet ID.

### Gist

```markdown
{{</* gist username gist-id */>}}
```

Embeds a GitHub Gist.

### Instagram

```markdown
{{</* instagram BWNjxxYMBw */>}}
```

Embeds an Instagram post.

## Custom Shortcodes

This is where the real power lies. Create a file in `layouts/shortcodes/` and it becomes available as a shortcode immediately.

### Example: A Quote Shortcode

Create `layouts/shortcodes/quote.html`:

```html
<blockquote class="custom-quote">
  <p>{{ .Inner | markdownify }}</p>
  {{ with .Get "author" }}
    <footer>— {{ . }}</footer>
  {{ end }}
</blockquote>
```

Usage in content:

```markdown
{{</* quote author="Albert Einstein" */>}}
Imagination is more important than knowledge.
{{</* /quote */>}}
```

### Shortcode Variables

Every shortcode template has access to these variables:

- `.Inner` — content between opening and closing shortcode tags
- `.Get "key"` — named parameter
- `.Get 0` — positional parameter
- `.Params` — slice of all positional params
- `.Page` — the Page object of the current content

### Shortcode with Positional Parameters

```html
{{ $name := .Get 0 }}
{{ $url := .Get 1 }}
<a href="{{ $url }}" class="btn">{{ $name }}</a>
```

Usage:

```markdown
{{</* btn "Download" "/files/example.pdf" */>}}
```

## Shortcode Best Practices

1. **Use named parameters** — they make your shortcodes self-documenting and easier to read.
2. **Handle errors gracefully** — check if required parameters exist and provide defaults.
3. **Use `markdownify`** — if your shortcode wraps content, pipe `.Inner` through `markdownify` to render Markdown inside it.
4. **Keep them focused** — each shortcode should do one thing well.
5. **Add comments** — shortcode templates can be complex; a brief comment helps future you.

## Debugging Shortcodes

If your shortcode isn't rendering as expected, run Hugo with:

```bash
hugo server --disableFastRender
```

This forces Hugo to rebuild every partial on every change. You can also use `{{</* myshortcode */>}}` (with `/*` and `*/`) to display the shortcode source instead of executing it — useful for documentation.

## Ordered and Unordered Shortcodes

Shortcodes come in two forms:

- **Unordered** — `{{</* shortcode */>}}` — no closing tag
- **Ordered** — `{{</* shortcode */>}}content{{</* /shortcode */>}}` — wraps content

Use ordered shortcodes when your template needs to process `.Inner`.

## Conclusion

Shortcodes are one of Hugo's standout features. They let you extend Markdown without breaking out of it, keeping your content portable and your templates maintainable. Whether you use built-in shortcodes or craft your own, they will make your Hugo site more dynamic and your writing workflow smoother.

## Reference
1. [Hugo Shortcodes Documentation](https://gohugo.io/content-management/shortcodes/)
2. [Hugo Template Lookup Order](https://gohugo.io/templates/lookup-order/)
