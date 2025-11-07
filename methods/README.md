# Method Library

This directory contains the canonical operational methods Delphi runs whenever a matching trigger occurs. Each method file documents:

- **Purpose** – why the method exists and the architectural principle it defends.
- **Triggers** – events or requests that force the method to run.
- **Inputs** – files, contexts, or approvals required before starting.
- **Procedure** – ordered checklist Delphi must follow.
- **Outputs** – artefacts that must exist (docs, tickets, TODOs) before the method is considered complete.
- **Validation** – analyzer/tests or reviews that close the loop.

Add new methods using the template in `../templates/method_template.md` so structure stays consistent.
