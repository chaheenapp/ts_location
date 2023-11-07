package qa.shaheen.tslocation

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

class TsLocationPlugin : FlutterPlugin, ActivityAware {

    companion object {

        /** Legacy for v1 embedding */
        @SuppressWarnings("deprecation")
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val service = BackgroundLocationService.getInstance()
            service.onAttachedToEngine(registrar.context(), registrar.messenger())
            registrar.addRequestPermissionsResultListener(service)
        }

        const val TAG = "qa.shaheen.Log.Tag"
        const val PLUGIN_ID = "qa.shaheen.tslocation"
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        BackgroundLocationService.getInstance()
                .onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        BackgroundLocationService.getInstance().onDetachedFromEngine()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val service = BackgroundLocationService.getInstance()
        service.setActivity(binding)
        binding.addRequestPermissionsResultListener(service)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        BackgroundLocationService.getInstance().setActivity(null)
    }
}
