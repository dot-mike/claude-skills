# Issue tracker — GitHub

Issues live in this repo's GitHub Issues.

**Remote**: `<repo-url>`

## Creating issues

```bash
gh issue create --title "<title>" --body "<body>" --label "<label>"
```

## Listing issues

```bash
gh issue list --label needs-triage
```

## Closing issues

```bash
gh issue close <number> --comment "<reason>"
```