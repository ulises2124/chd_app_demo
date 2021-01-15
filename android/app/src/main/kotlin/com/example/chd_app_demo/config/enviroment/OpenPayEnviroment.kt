package com.example.chd_app_demo.config.enviroment

interface OpenPayEnviroment {
    fun openPayGetMerchantId():String
    fun openPayGetApiKey():String
    fun openPayIsProductionMode():Boolean
}