package com.joytech.hexcy

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * PGInAppSDK returns to its "return activity" with NEW_TASK | CLEAR_TASK, which
 * would destroy and restart hexy. This invisible activity lives in its own task,
 * so only that task is cleared; it forwards the payment result to the existing
 * MainActivity (onNewIntent) without recreating it.
 */
class PgReturnActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startActivity(
            Intent(this, MainActivity::class.java)
                .putExtras(intent.extras ?: Bundle())
                .addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP,
                ),
        )
        finish()
    }
}
