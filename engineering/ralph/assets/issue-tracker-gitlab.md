# Issue tracker — GitLab

Issues live in this repo's GitLab Issues.

**Remote**: `<repo-url>`

## Creating issues

```bash
glab issue create --title "<title>" --description "<body>" --label "<label>"
```

## Listing issues

```bash
glab issue list --label needs-triage
```

## Closing issues

```bash
glab issue close <number> --note "<reason>"
```
