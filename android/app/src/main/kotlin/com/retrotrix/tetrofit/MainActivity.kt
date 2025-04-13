package com.retrotrix.tetrofit

import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // // Đặt flags FULLSCREEN trước khi vẽ UI
        // window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        // window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)

        // val rootView = findViewById<View>(android.R.id.content)
        // rootView.setPadding(0, 0, 0, 0)

        // hideSystemBars()
    }

    /** Hide virtual navigation, status bars */
    private fun hideSystemBars() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).let { controller ->
            controller.hide(WindowInsetsCompat.Type.systemBars())
            controller.systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }
}
