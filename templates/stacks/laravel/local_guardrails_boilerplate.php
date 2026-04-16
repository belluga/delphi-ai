<?php

/**
 * PACED Local Project Guardrails (Laravel)
 * 
 * This file is automatically loaded by the global architecture_guardrails.php engine.
 * Add project-specific architectural rules and business-logic constraints here.
 */

return [
    /**
     * Project-specific coupling rules
     * Example: 'Checkout' module cannot talk to 'Admin' module.
     */
    'checkProjectCoupling' => function ($files) {
        $violations = [];
        // Implementation here...
        return $violations;
    },

    /**
     * Domain-specific validation
     * Example: Ensure all DTOs implement a specific interface.
     */
    'checkProjectDTOs' => function ($files) {
        $violations = [];
        // Implementation here...
        return $violations;
    },
];
