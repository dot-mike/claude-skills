# claude-skills

A personal collection of Claude agent skills published via the `npx skills@latest` registry to `dot-mike/claude-skills` on Github.

## Project Structure

```
claude-skills/
├── <skill-name>/          # One directory per skill
│   ├── SKILL.md           # Required: frontmatter (name, description) + instructions
│   ├── references/        # Optional: reference docs loaded on demand
│   ├── scripts/           # Optional: helper scripts
│   └── assets/            # Optional: templates, icons, other static files
└── README.md
```

Each skill directory at the repo root is a self-contained skill package. Skills can be installed with:

```bash
npx skills@latest add dot-mike/claude-skills/<skill-name>
```

## Creating a New Skill

**Always use the `write-a-skill` skill** when building or improving a skill in this repo:

```
/write-a-skill
```

## Updating README.md

After adding a new skill, add it to the README under the appropriate section with its install command:

```bash
npx skills@latest add dot-mike/claude-skills/<skill-name>
```
