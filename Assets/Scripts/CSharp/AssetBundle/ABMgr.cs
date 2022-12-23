using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
[LuaCallCSharp]
public class ABMgr : SingleAutoMono<ABMgr>
{
    private Dictionary<string, AssetBundle> cache = new Dictionary<string, AssetBundle>();
    // ����
    private AssetBundle mainAB = null;
    // ��������
    private AssetBundleManifest manifest = null;
    // Start is called before the first frame update

    // ������Դ��
    private void LoadAB(string abName)
    {   
        // ����û���������
        if(mainAB == null)
        {
            mainAB = AssetBundle.LoadFromFile(Application.persistentDataPath + "/PC");
            manifest = mainAB.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        // ����������
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
        // ����Ŀ���
        if (!cache.ContainsKey(abName))
        {
            temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + abName);
            cache.Add(abName, temp);
        }
        

    }

    // ������Դ
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
            // ��ж�ؼ��ص���Դ����
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
