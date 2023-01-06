using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using XLua;
public class Main : MonoBehaviour
{
    private LuaEnv luaEnv;

    // Lua�ű������� ����Ҫ�ǲ�ȫ·������Ӧ·�����ء�
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
            Debug.LogError("�޷�����Lua�ű�");
            return null;
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        luaEnv = new LuaEnv();
        // ����������Ƿ���Ҫ����
        ABUpdateMgr.Instance.CheckABUpdate();
        luaEnv.AddLoader(LuaScriptsCustomLoad);

        // ����main�ű�
        luaEnv.DoString("require ('Main')");
        

    }




}
