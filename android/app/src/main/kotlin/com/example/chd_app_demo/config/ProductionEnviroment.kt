package com.example.chd_app_demo.config;
import com.example.chd_app_demo.config.enviroment.Enviroment

object ProductionEnviroment: Enviroment() {
    override val openPayMerchantId: String        = "maguopugd9yegq2h8bhy";
    override val openPayApiKey: String            = "sk_16ca01aaec244c1d8b0e6eebc1e9ca3c";
    override val openPayIsProductionMode: Boolean = true;
}