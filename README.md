# Recipe Cycle — Project Overview

## Purpose
This project is being built primarily as a **learning exercise** for the Flutter + Dart + Node/Express + MongoDB stack. The goal is to get hands-on, working experience with each layer of this stack so the team is equipped to take on larger, more complex apps afterward. The app itself (Recipe Cycle) is a real, usable MVP — but the priority is understanding *how* each piece works, not just shipping fast.

## The Problem
People often have ingredients sitting at home (fridge/pantry) but don't know what to cook with them. This leads to food waste and repetitive, uninspired meals.

## The Solution
Recipe Cycle lets users select the ingredients they already have at home, and suggests recipes they can make — prioritizing recipes that use the most of what's on hand.

## Tech Stack
| Layer | Technology |
|---|---|
| Frontend (mobile) | Flutter (Dart) |
| Backend | Node.js + Express |
| Database | MongoDB |
| Version control | GitHub |

## Core Feature (MVP)
1. User opens the app and sees a **checklist of common ingredients**, grouped by category (vegetables, dairy, grains, spices, proteins, etc.)
2. User **ticks the ingredients they currently have** at home
3. The backend matches selected ingredients against the recipe database and returns recipes **ranked by match percentage** (e.g. "You have 4 of 5 ingredients — missing: garlic")
4. User can mark an ingredient as "used" after cooking

## Ingredient Input Method: Checklist (Tick-Based)
**Decision:** Use a pre-built checklist of common ingredients rather than free text input.

**Why:**
- No typos or mismatches (e.g. "tomato" vs "tomatoes") to handle on the backend
- Faster for users — tap instead of type
- Guarantees clean matching against the recipe database

**Requirements for this checklist:**
- Cover most commonly used/available ingredients (aim for a broad, practical list — not exhaustive, but not sparse either)
- Organize by category so items are easy to find (e.g. Vegetables, Fruits, Dairy, Grains & Starches, Proteins, Spices & Condiments)
- Consider a search/filter bar on top of the checklist for large lists

## Recipe Matching Logic
**Decision:** Rule-based matching (no AI required for MVP).

- Each recipe document in MongoDB stores an `ingredients` array
- User's selected ingredients are compared against each recipe's ingredient list
- Backend calculates overlap and returns recipes sorted by highest match %
- **AI is a possible future/stretch feature** — e.g. suggesting ingredient substitutions — but not required for the core app to work

## Data Structure (Draft — to refine with team)
**Recipe document (MongoDB):**
- name
- ingredients (array)
- steps (array)
- category/tags
- prep time

**Ingredient list (MongoDB or static):**
- name
- category (for grouping in the checklist UI)

## GitHub Setup
- Repo created: `Recipe-Cycle`
- `.gitignore`: Dart template (ignores Flutter build/generated files)
- Workflow: each member works on a separate branch, merges into `main` via Pull Requests (avoid pushing directly to `main`)

## Build Order
1. Finalize MVP scope (this doc)
2. Set up GitHub repo + branching workflow
3. Design MongoDB schema for recipes and ingredients
4. Build backend API (routes: get recipes, get ingredient list, match ingredients → recipes)
5. Build Flutter checklist UI + recipe results screen
6. Connect frontend to backend, test full flow
7. Iterate: UI polish, "mark as used" feature, stretch goals
