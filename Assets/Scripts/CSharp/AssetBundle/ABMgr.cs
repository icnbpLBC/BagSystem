using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using XLua;
using Object = UnityEngine.Object;

[LuaCallCSharp]
public class ABMgr : SingleAutoMono<ABMgr>
{
    // 缓存AB包 key为ab包名 value为ab包
    private Dictionary<string, AssetBundle> cacheAB = new Dictionary<string, AssetBundle>();
    // 记录引用计数
    private Dictionary<string, Dictionary<string, int>> referenceCount = new Dictionary<string, Dictionary<string, int>>();
    // 缓存资源
    private Dictionary<string, Dictionary<string, Object>> cacheAsset = new Dictionary<string, Dictionary<string, Object>>();
    // 准备释放的资源
    private Dictionary<string, Dictionary<string, float>> readyToRelease = new Dictionary<string, Dictionary<string, float>>();

    // 主包
    private AssetBundle mainAB = null;
    // 主包配置
    private AssetBundleManifest manifest = null;
    // Start is called before the first frame update


    private float defaultExpireTime = 1.5f;

    // 加载资源包
    private AssetBundle LoadAB(string abName)
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
            if (!cacheAB.ContainsKey(depend))
            {
                temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + depend);
                cacheAB.Add(depend, temp);
            }
        }
        // 加载目标包
        if (!cacheAB.ContainsKey(abName))
        {
            temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + abName);
            cacheAB.Add(abName, temp);
        }
        return cacheAB[abName];

    }

    // 从缓存中获取已加载的资源对象
    private UnityEngine.Object GetObject(string abName, string resName)
    {
        if(cacheAsset.ContainsKey(abName) && cacheAsset[abName].ContainsKey(resName))
        {
            return cacheAsset[abName][resName];
        }
        return null;
    }

    // 增加资源引用计数
    public void AddReferenceCount(string abName, string resName)
    {
        if (!referenceCount.ContainsKey(abName))
        {
            referenceCount.Add(abName, new Dictionary<string, int>());
        }
        if (!referenceCount[abName].ContainsKey(resName))
        {
            referenceCount[abName].Add(resName, 0);
        }
        referenceCount[abName][resName]++;

        // 更改准备释放资源列表
        if (readyToRelease.ContainsKey(abName) && readyToRelease[abName].ContainsKey(resName))
        {
            readyToRelease[abName].Remove(resName);
        } 
    }

    // 减少资源引用
    public void DecreaseReferenceCount(string abName, string resName)
    {
        if (!referenceCount.ContainsKey(abName)) Debug.LogError(string.Format("The ab: '{0}' is unloaded ", abName));
        if(!referenceCount[abName].ContainsKey(resName)) Debug.LogError(string.Format("The ab: '{0}' res: '{1}' is unloaded ", abName, resName));
        referenceCount[abName][resName]--;

        // todo 依赖项引用同样减【依赖项只有ab包,没有对应资源】

        // 资源释放
        if(referenceCount[abName][resName] <= 0)
        {
            if (!readyToRelease.ContainsKey(abName)) readyToRelease[abName] = new Dictionary<string, float>();
            readyToRelease[abName][resName] = Time.time;
           
        }

    }

    public void UpdateRelease()
    {
        // 是否需要释放资源
        if (readyToRelease.Count <= 0) return;
        // 获取过去时间
        float nowTime = Time.unscaledTime;
        Dictionary<string, string> temp = new Dictionary<string, string>();
        foreach (var entryAB in readyToRelease)
        {

            foreach(var entryAsset in readyToRelease[entryAB.Key])
            {
                if ((nowTime - entryAsset.Value) < defaultExpireTime) continue;

                // 释放资源
                temp.Add(entryAB.Key, entryAsset.Key);
                Destroy(cacheAsset[entryAB.Key][entryAsset.Key]);
                cacheAsset[entryAB.Key].Remove(entryAsset.Key);
            }

            // 包释放
            if (referenceCount[entryAB.Key].Count <= 0)
            {
                cacheAB[entryAB.Key].Unload(true);
                cacheAB.Remove(entryAB.Key);
            }
        }



        // 已释放资源 不再重新释放
        foreach(var entry in temp)
        {
            readyToRelease[entry.Key].Remove(entry.Value);
        }

    }
   

    // 存放资源的缓存
    private void PutAssetInCache(string abName, string resName, Object obj)
    {
        if (!cacheAsset.ContainsKey(abName)) cacheAsset.Add(abName, new Dictionary<string, Object>());
        cacheAsset[abName][resName] = obj;
    }

    // 加载资源 mode - 0 ：异步方式加载， mode - 1 ：同步方式加载
    public void LoadRes(string abName, string resName, System.Type type, System.Action<Object> finishedCB, int mode)
    { 
        Object res = GetObject(abName, resName);
        if (res != null)
        {
            finishedCB(res);
        }
        else
        {
           if(mode == 0)
            {
                LoadResAsync(abName, resName, type, finishedCB);
            }
            else
            {
                LoadResSync(abName, resName, type, finishedCB);
            }

        }
    }

    // 同步方式加载资源
    private void LoadResSync(string abName, string resName, System.Type type, System.Action<Object> finishedCB)
    {
        LoadAB(abName);
        Object obj = cacheAB[abName].LoadAsset(resName, type);
        PutAssetInCache(abName, resName, obj);
        finishedCB(obj);
    }


    // 异步方式加载资源
    public void LoadResAsync(string abName, string resName, System.Type type, System.Action<Object> finishedCB)
    {
        AssetBundle ab = LoadAB(abName); // ab包同步加载
        StartCoroutine(LoadRes(ab, resName, type, finishedCB));
    }

    private IEnumerator LoadRes(AssetBundle assetBundle, string resName, System.Type type, System.Action<Object> finishedCB)
    {
        AssetBundleRequest abr = assetBundle.LoadAssetAsync(resName, type);
        yield return abr;
        PutAssetInCache(assetBundle.name, resName, abr.asset);
        finishedCB(abr.asset);
    }


    public void UnLoad(string abName)
    {
        if (cacheAB.ContainsKey(abName))
        {   
            // 不卸载加载的资源对象
            cacheAB[abName].Unload(false);
            cacheAB.Remove(abName);
        }
    }

    public void UnLoadAll()
    {
        AssetBundle.UnloadAllAssetBundles(false);
        cacheAB.Clear();
        mainAB = null;
        manifest = null;
    }


}

