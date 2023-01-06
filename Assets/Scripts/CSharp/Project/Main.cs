using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using XLua;
public class Main : MonoBehaviour
{
    private LuaEnv luaEnv;

    // Lua脚本加载器 【主要是补全路径到对应路径加载】
    public byte[] LuaScriptsCustomLoad(ref string fileName)
    {
        string filePath = Application.dataPath + "/Scripts/Lua/" + fileName + ".lua";
        Debug.Log(filePath);
        if (File.Exists(filePath))
        {
            return File.ReadAllBytes(filePath);
        }
        else
        {
            Debug.LogError("无法加载Lua脚本");
            return null;
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        luaEnv = new LuaEnv();
        // 已启动检查是否需要更新
        ABUpdateMgr.Instance.CheckABUpdate();
        luaEnv.AddLoader(LuaScriptsCustomLoad);

        // 加载main脚本
        luaEnv.DoString("require ('Main')");
        

    }




}
