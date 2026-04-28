# Fixed-to-Free RPG Conversion Prompts

Prompt library for converting IBM i RPG source from fixed format to free format using a **Research → Plan → Implement** workflow.

The prompts are designed to minimize hallucinations and preserve behavior:

- Keep business logic unchanged
- Do not invent files, procedures, data structures, copy members, service programs, or libraries
- Base every conclusion only on source actually present in the codebase
- Prefer small, reviewable changes over whole-program rewrites
- Explicitly mark any uncertainty instead of guessing

---

## Core Conversion Rules to Include in Every Prompt

Use this guardrail block in every session, especially before asking for plans or code changes.

```text
Guardrails for this task:
- Preserve business logic exactly unless I explicitly ask for a functional change.
- Do not invent or assume any data structures, files, prototypes, copybooks, procedures, service programs, binding directories, commands, or libraries that are not present in the provided source or discovered in the repository.
- If a dependency is not visible, say "not verified from available source" instead of guessing.
- Keep names exactly as they exist in source unless I explicitly ask for renaming.
- Distinguish clearly between facts observed in code and recommendations.
- Make the smallest safe change set possible.
- For fixed-to-free conversion, focus on syntax modernization, not redesign.
- Before proposing code, identify which members, copybooks, display files, physical/logical files, and called procedures are actually referenced by the target source member.
```

---

## Workflow Overview

1. **Research**  
   Understand the source member, its dependencies, and the exact conversion scope.
2. **Plan**  
   Produce a short, reviewable change plan with explicit non-goals and risks.
3. **Implement**  
   Convert only the agreed scope, then self-check against the source.

---

## 1. Research Prompts

Use these first. The goal is to understand the target member before changing anything.

### 1.1 Initial inventory of a target member

```text
I want to prepare a fixed-to-free RPG conversion.

Target member:
[paste member path here]

Guardrails for this task:
- Preserve business logic exactly unless I explicitly ask for a functional change.
- Do not invent or assume any data structures, files, prototypes, copybooks, procedures, service programs, binding directories, commands, or libraries that are not present in the provided source or discovered in the repository.
- If a dependency is not visible, say "not verified from available source" instead of guessing.
- Keep names exactly as they exist in source unless I explicitly ask for renaming.
- Distinguish clearly between facts observed in code and recommendations.
- Make the smallest safe change set possible.
- For fixed-to-free conversion, focus on syntax modernization, not redesign.

Please analyze only what can be verified from the repository and provide:
1. Whether the member is fixed-format, mixed-format, or already fully free-format
2. Its program/module role
3. Files, display files, printer files, copy members, and external procedures it references
4. Internal subroutines or procedures it contains
5. Indicators, data areas, and externally-described structures it depends on
6. A list of specific constructs that would need conversion (for example F-specs, D-specs, C-spec calcs, BEGSR/ENDSR, MOVE/MOVEL/Z-ADD, fixed-format IF/DO/SELECT, result indicators)

Do not propose code yet. If something is not visible in the repository, label it as not verified.
```

### 1.2 Dependency-grounded research

```text
Using the target member and any directly referenced repository files only, build a dependency summary for fixed-to-free conversion.

Return these sections:
- Verified source dependencies
- Verified database/display/printer dependencies
- Verified called procedures/programs
- Unverified dependencies that would require more source to confirm
- Conversion-sensitive areas where a syntax rewrite could accidentally change behavior

For each dependency, cite the exact member or line context it came from.
Do not infer missing prototypes or data structures.
```

### 1.3 Business-logic protection review

```text
Before any conversion, identify the business-logic-critical parts of this RPG member.

Focus on:
- validation logic
- calculations
- status handling
- indicator-driven behavior
- file I/O sequencing
- subfile control logic
- error handling and early exits
- calls to external programs or procedures

For each item:
1. quote or reference the relevant source area
2. explain why it is business-critical
3. explain what could go wrong during a fixed-to-free rewrite

Do not suggest redesigns. This is only a behavior-preservation review.
```

### 1.4 Scope sizing prompt

```text
Recommend a safe conversion scope for this member.

Choose one of:
- subroutine-level conversion only
- procedure-level conversion only
- declarations plus one routine
- entire member conversion

Base the recommendation only on verified code structure, complexity, and dependency visibility.

Return:
- recommended scope
- why this is the safest reviewable unit
- what is explicitly out of scope
- what repository files should be reviewed together before implementation

Do not write code yet.
```

### 1.5 Repository exploration prompt for larger codebases

```text
I am preparing a fixed-to-free conversion in an IBM i codebase.

Using only repository evidence, identify the files I should inspect before converting this member:
[target member path here]

Please group findings into:
- directly included copy members
- likely prototype/include members
- called service-program procedures
- related display files or printer files
- related database objects
- build or binding definitions that affect compilation
- nearby members that use the same patterns and could act as reference examples

Do not guess relationships. If a relationship is only likely, mark it as probable, not verified.
```

---

## 2. Plan Prompts

Use these after research is complete. The output should be short and reviewable.

### 2.1 Brief reviewable conversion plan

```text
Create a brief reviewable plan for converting this RPG member from fixed to free format.

Target:
[target member path here]

Use only verified findings from prior analysis.

Plan requirements:
- preserve business logic exactly
- no new procedures, files, or data structures unless already present in source
- no renaming unless explicitly required
- keep the plan short enough for code review

Return exactly these sections:
1. Scope
2. Verified dependencies to preserve
3. Conversion steps in execution order
4. Risk points to review carefully
5. Explicit non-goals
6. Validation checklist

Do not generate code.
```

### 2.2 Ultra-short approval plan

```text
Create a very short approval-ready plan for this fixed-to-free conversion.

Constraints:
- maximum 10 bullets
- each bullet must be concrete and reviewable
- only use facts verified from repository source
- explicitly state that business logic remains unchanged
- explicitly state that no missing dependencies will be invented

Do not generate code.
```

### 2.3 Plan with line-oriented change map

```text
Produce a line-oriented conversion plan for this member.

For each planned change area, identify:
- source section or line range
- current construct type (for example fixed F-spec, fixed D-spec, BEGSR/ENDSR, calc specs, fixed IF)
- intended free-format equivalent
- behavior-preservation note
- dependency or risk note

Do not write converted code yet.
Do not include any line ranges you cannot verify from the source provided.
```

### 2.4 Reviewer challenge prompt

```text
Review the proposed fixed-to-free conversion plan critically.

Identify:
- any steps that could accidentally alter business logic
- any places where hidden dependencies may exist
- any plan items that assume objects not verified in source
- any steps that are too large for safe review
- any missing validation checks

Return a corrected, safer plan if needed.
Do not generate code.
```

---

## 3. Implement Prompts

Use these only after the plan has been reviewed.

### 3.1 Implement the agreed scope only

```text
Implement the agreed fixed-to-free conversion for this RPG member.

Target:
[target member path here]

Mandatory constraints:
- preserve business logic exactly
- do not invent missing files, procedures, prototypes, copy members, data structures, service programs, or libraries
- do not rename existing identifiers unless explicitly requested
- convert only the agreed scope, not the entire member unless that scope was approved
- retain the same control flow, file access order, and indicator behavior
- if a construct cannot be safely converted from visible source alone, stop and explain why

Output format:
1. short summary of what was converted
2. the converted code only for the approved scope
3. a bullet list of anything intentionally left unchanged
4. a bullet list of any uncertainties marked as not verified

Do not add extra improvements beyond syntax modernization.
```

### 3.2 Subroutine-to-procedure conversion with strict preservation

```text
Convert this specific fixed-format subroutine to free-format RPG.

Target member:
[target member path here]

Target routine:
[routine name here]

Rules:
- preserve logic exactly
- do not change data names
- do not introduce helper procedures unless they already exist
- do not replace indicators with booleans unless that change is already present elsewhere and explicitly approved
- keep file operations in the same order
- preserve loop and conditional semantics exactly
- if converting BEGSR/ENDSR to Dcl-Proc would change call semantics in this member, explain that risk before generating code

First provide a 5-bullet safety check.
Then provide the converted code.
Then provide a source-to-source mapping of old constructs to new constructs.
```

### 3.3 Full-member conversion with no redesign

```text
Convert this RPG member from fixed format to free format with no functional redesign.

Requirements:
- preserve all business logic exactly
- preserve compile-time dependencies exactly as verified in source
- preserve copy/include relationships
- preserve called program/procedure names
- do not invent prototypes or external definitions that are not present in the repository
- retain comments where possible
- keep the member structurally familiar for reviewers

After the code, include:
- a "Behavior preserved by" checklist
- a "Not changed" checklist
- a "Needs repository verification" checklist for anything not fully visible
```

### 3.4 Minimal-diff implementation prompt

```text
Implement this fixed-to-free conversion as a minimal diff.

Priorities in order:
1. preserve behavior
2. minimize reviewer cognitive load
3. avoid unrelated cleanup
4. avoid renaming
5. keep formatting consistent

Please:
- convert only syntax that must change for the approved scope
- leave surrounding logic untouched where possible
- call out any lines where a syntactic change could conceal a semantic change

Return:
- minimal-diff converted code
- reviewer notes for the risky lines only
```

---

## 4. Verification and Review Prompts

Use these immediately after implementation.

### 4.1 Logic-preservation review

```text
Review this fixed-to-free conversion for behavior preservation.

Compare the converted code against the original and check for:
- changed branch conditions
- changed loop boundaries
- changed indicator usage
- changed file I/O order
- changed initialization behavior
- changed parameter passing semantics
- changed default values or data types
- newly introduced dependencies or invented objects

Return:
1. confirmed preserved behaviors
2. suspected behavior changes
3. invented or unverified references, if any
4. reviewer questions that must be resolved before compile/testing
```

### 4.2 Hallucination check

```text
Audit this conversion for hallucinations.

List anything in the converted output that is not directly verified from the repository source, including:
- procedures
- prototypes
- copybooks
- libraries
- files
- data structures
- constants
- compile options
- service programs

If everything is grounded in source, say so explicitly.
```

### 4.3 Reviewable summary for pull request or code review

```text
Create a concise review summary for this fixed-to-free RPG conversion.

Include:
- what was converted
- what was intentionally not changed
- which dependencies were verified from source
- why business logic should be unchanged
- which areas need special reviewer attention

Keep it concise and evidence-based.
```

### 4.4 Compile-readiness prompt

```text
Based only on visible repository evidence, assess whether this converted member appears compile-ready.

Check:
- includes/copy members still align with usage
- declarations appear consistent with referenced fields and indicators
- called procedures/programs are still referenced with the same names
- no obviously invented dependencies were introduced
- conversion did not remove required fixed-format constructs that still have no verified free-format equivalent in this context

Do not claim successful compilation unless there is actual compile evidence.
Return only an evidence-based readiness assessment.
```

---

## 5. Reusable Prompt Chains

Ready-made prompt sequences are now in a separate file: [`prompt-chains.md`](dadjoke-rpg/prompt-chains.md)

---

## 6. Recommended Output Rules for the AI

When you use the prompts above, add these output rules if you want tighter responses.

```text
Output rules:
- Be concise.
- Use headings and bullets.
- Separate "Verified" from "Not verified".
- Cite member names and line ranges where possible.
- If proposing code, change only the approved scope.
- If a safe implementation is not possible from visible source alone, stop instead of guessing.
```

---

## 7. Practical Notes

- Start with one routine, subroutine, or tightly bounded section before attempting whole-member conversion.
- In RPG, syntax changes can accidentally alter semantics around indicators, file positioning, operation extenders, and subfile logic; explicitly ask for those to be preserved.
- If the target uses `/COPY` or `/INCLUDE`, inspect those members before allowing the AI to propose declarations or prototypes.
- If compile and bind behavior matters, inspect build artifacts such as `Rules.mk`, binding source, and include members before implementation.
- For SQLRPGLE or display-file-heavy programs, prefer smaller scopes because hidden dependencies are more common.
- Ask for a hallucination audit after every implementation response.

---

## 8. One Prompt to Copy When You Need a Strong Default

```text
I want help converting RPG from fixed format to free format using a Research → Plan → Implement workflow.

Target:
[paste member path and optional line/routine scope here]

Guardrails for this task:
- Preserve business logic exactly unless I explicitly ask for a functional change.
- Do not invent or assume any data structures, files, prototypes, copybooks, procedures, service programs, binding directories, commands, or libraries that are not present in the provided source or discovered in the repository.
- If a dependency is not visible, say "not verified from available source" instead of guessing.
- Keep names exactly as they exist in source unless I explicitly ask for renaming.
- Distinguish clearly between facts observed in code and recommendations.
- Make the smallest safe change set possible.
- For fixed-to-free conversion, focus on syntax modernization, not redesign.

Step 1: Research
- Determine the exact conversion scope
- List verified dependencies
- Identify business-logic-critical areas
- Identify conversion-sensitive constructs
- Mark anything unverified

Step 2: Plan
- Produce a brief reviewable plan
- State explicit non-goals
- State validation checks
- Do not write code yet

Step 3: Implement
- Convert only the approved scope
- Preserve control flow, file I/O order, indicator behavior, and names
- Do not invent dependencies
- Keep the diff minimal

Step 4: Verify
- Check for logic drift
- Check for invented objects
- Check compile-readiness based only on visible source
- Summarize what changed and what did not

Use repository evidence only. If something cannot be verified safely, say so and stop.