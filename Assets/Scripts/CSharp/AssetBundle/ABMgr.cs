using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
[LuaCallCSharp]
public class ABMgr : SingleAutoMono<ABMgr>
{
    private Dictionary<string, AssetBundle> cache = new Dictionary<string, AssetBundle>();
    // 主包
    private AssetBundle mainAB = null;
    // 主包配置
    private AssetBundleManifest manifest = null;
    // Start is called before the first frame update

    // 加载资源包
    private void LoadAB(string abName)
    {   
        // 主包没加载则加载
        if(mainAB == null)
        {
            mainAB = AssetBundle.LoadFromFile(Application.persistentDataPath + "/PC");
            manifest = mainAB.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        // 加载依赖包
        string[] dependencies = manifest.GetAllDependencies(abName);

        AssetBundle temp;
        foreach(string depend in dependencies)
        {
            if (!cache.ContainsKey(depend))
            {
                temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + depend);
                cache.Add(depend, temp);
            }
        }
        // 加载目标包
        if (!cache.ContainsKey(abName))
        {
            temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + abName);
            cache.Add(abName, temp);
        }
        

    }

    // 加载资源
    public Object LoadRes(string abName, string resName, System.Type type, Transform parent = null)
    {
        LoadAB(abName);
        Object obj = cache[abName].LoadAsset(resName, type);
        if(obj is GameObject)
        {
            if (parent != null) return Instantiate(obj, parent);
            return Instantiate(obj);
        }
        return obj;
    }


    public void UnLoad(string abName)
    {
        if (cache.ContainsKey(abName))
        {   
            // 不卸载加载的资源对象
            cache[abName].Unload(false);
            cache.Remove(abName);
        }
    }

    public void UnLoadAll()
    {
        AssetBundle.UnloadAllAssetBundles(false);
        cache.Clear();
        mainAB = null;
        manifest = null;
    }
}
