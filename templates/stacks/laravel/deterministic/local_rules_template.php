<?php

/**
 * PACED Project-Specific Architectural Rules (Laravel)
 * 
 * This file is where local business-logic constraints are defined.
 * The Delphi agent uses this template to instantiate new project-specific rules.
 */

return [
    /**
     * Example: checkBusinessConstraint
     * Description: Ensures that module A does not call module B directly.
     */
    'checkBusinessConstraint' => function (array $files, string $repoRoot): array {
        $violations = [];
        // Implementation logic here...
        // $violations[] = new ArchitectureViolation('PROJ-BUS-01', $file, $line, 'Violation message');
        return $violations;
    },
];
