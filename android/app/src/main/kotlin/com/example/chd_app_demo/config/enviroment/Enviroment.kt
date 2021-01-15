package com.example.chd_app_demo.config.enviroment

abstract class Enviroment: OpenPayEnviroment, MercuryEnviroment{
    protected abstract val openPayMerchantId:String;
    protected abstract val openPayApiKey:String;
    protected abstract val openPayIsProductionMode:Boolean;

    override final fun openPayGetMerchantId(): String {
        return openPayMerchantId;
    }

    override final fun openPayGetApiKey(): String {
        return openPayApiKey;
    }

    override final fun openPayIsProductionMode():Boolean{
        return openPayIsProductionMode;
    }

}