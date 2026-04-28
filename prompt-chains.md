# Reusable Prompt Chains

Ready-made prompt sequences for fixed-to-free RPG conversion that can be run end-to-end.

---

## 5.1 Safe small-scope chain

#### Prompt A — Research
```text
I want to convert a small part of an RPG member from fixed to free format.

Target member:
[target member path here]

Guardrails for this task:
- Preserve business logic exactly unless I explicitly ask for a functional change.
- Do not invent or assume any data structures, files, prototypes, copybooks, procedures, service programs, binding directories, commands, or libraries that are not present in the provided source or discovered in the repository.
- If a dependency is not visible, say "not verified from available source" instead of guessing.
- Keep names exactly as they exist in source unless I explicitly ask for renaming.
- Distinguish clearly between facts observed in code and recommendations.
- Make the smallest safe change set possible.
- For fixed-to-free conversion, focus on syntax modernization, not redesign.

Please recommend the smallest safe reviewable conversion scope and identify all verified dependencies for that scope only.
Do not write code.

Write your research findings to: [member-name]-research.md
```

#### Prompt B — Plan
```text
Read the research findings from: [member-name]-research.md

Using the verified research findings only, create a short reviewable conversion plan for the approved small scope.

Return:
- scope
- steps
- risks
- non-goals
- validation checklist

Do not write code.

Write your plan to: [member-name]-plan.md
```

#### Prompt C — Implement
```text
Read the conversion plan from: [member-name]-plan.md

Implement only the approved small-scope fixed-to-free conversion.

Requirements:
- preserve business logic exactly
- no invented dependencies
- no unrelated cleanup
- no renaming
- minimal diff preferred

Return the converted code plus a short preservation checklist.

Update the plan file [member-name]-plan.md with:
- Implementation status for each step
- Any deviations from the plan
- Preservation checklist
```

#### Prompt D — Verify
```text
Read the plan and implementation details from: [member-name]-plan.md

Review the conversion and identify any possible behavior change, invented dependency, or unverified assumption.

Keep the review evidence-based and concise.

Add a new "Verification" section to [member-name]-plan.md with:
- Verification findings
- Behavior change analysis
- Dependency validation
- Assumption checks
- Final approval status
```

## 5.2 Full-member chain

#### Prompt A — Research
```text
Analyze this RPG member for full fixed-to-free conversion readiness.

Target:
[target member path here]

Return:
- verified dependencies
- conversion-sensitive constructs
- hidden-risk areas
- whether full-member conversion is safe or whether a smaller scope is better

Do not write code.

Write your research findings to: [member-name]-research.md
```

#### Prompt B — Plan
```text
Read the research findings from: [member-name]-research.md

Create a brief full-member conversion plan with explicit non-goals and a validation checklist.

No code yet.

Write your plan to: [member-name]-plan.md
```

#### Prompt C — Implement
```text
Read the conversion plan from: [member-name]-plan.md

Perform the full-member fixed-to-free conversion with no redesign and no invented dependencies.

After the code, include:
- unchanged behaviors
- unchanged dependencies
- unverified items, if any

Update the plan file [member-name]-plan.md with:
- Implementation status for each step
- Any deviations from the plan
- Preservation checklist
```

#### Prompt D — Verify
```text
Read the plan and implementation details from: [member-name]-plan.md

Audit the full-member conversion for:
- logic drift
- invented objects
- missed dependencies
- compile-readiness concerns

Keep findings tied to repository evidence only.

Add a new "Verification" section to [member-name]-plan.md with:
- Verification findings
- Logic drift analysis
- Dependency validation
- Compile-readiness assessment
- Final approval status