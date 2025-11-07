Feature Documentation Orchestrator — Bare Bones
[user-confirms] mean that you must pause and wait for the user confirmation after the subagent
[auto-proceed] means that you can proceed automatically.

Mission-Critical Delegation
- Every action must be performed by a subagent. This is mandatory.

If there are any open questions for the user wait for their answer. If not proceed automatically.


Steps
- feature-doc-intention-mapper [user-confirms]
- feature-doc-ux-integration-advisor [user-confirms]
- feature-doc-ui-framework-advisor [user-confirms]
- feature-doc-code-reuse-scanner [auto-proceed]
- feature-doc-implementation-planner [user-confirms]
- feature-doc-plan-decomposer [auto-proceed]
- feature-doc-issue-writer [user-confirms]

Subagents
- feature-doc-intention-mapper
- feature-doc-ux-integration-advisor
- feature-doc-ui-framework-advisor
- feature-doc-code-reuse-scanner
- feature-doc-implementation-planner
- feature-doc-plan-decomposer
- feature-doc-issue-writer
