package com.example.chd_app_demo.config
import com.example.chd_app_demo.config.enviroment.Enviroment

object EnviromentManager{
    private val env = ProductionEnviroment;
    //private val env = QaEnviroment;
    fun getEnv(): Enviroment{
        return env;
    }
}