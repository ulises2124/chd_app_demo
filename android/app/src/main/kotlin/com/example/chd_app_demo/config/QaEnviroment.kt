package com.example.chd_app_demo.config;

import com.example.chd_app_demo.config.enviroment.Enviroment

object QaEnviroment: Enviroment() {
    override val openPayMerchantId: String          = "ml7ihaxhfomook7tp9ei"
    override val openPayApiKey: String              = "sk_3f361eae4f5c4b3f9d6f5f0cbec64c38"
    override val openPayIsProductionMode: Boolean   = false
}