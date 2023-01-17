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
    // ����AB�� keyΪab���� valueΪab��
    private Dictionary<string, AssetBundle> cacheAB = new Dictionary<string, AssetBundle>();
    // ��¼���ü���
    private Dictionary<string, Dictionary<string, int>> referenceCount = new Dictionary<string, Dictionary<string, int>>();
    // ������Դ
    private Dictionary<string, Dictionary<string, Object>> cacheAsset = new Dictionary<string, Dictionary<string, Object>>();
    // ׼���ͷŵ���Դ
    private Dictionary<string, Dictionary<string, float>> readyToRelease = new Dictionary<string, Dictionary<string, float>>();

    // ����
    private AssetBundle mainAB = null;
    // ��������
    private AssetBundleManifest manifest = null;
    // Start is called before the first frame update


    private float defaultExpireTime = 1.5f;

    // ������Դ��
    private AssetBundle LoadAB(string abName)
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
            if (!cacheAB.ContainsKey(depend))
            {
                temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + depend);
                cacheAB.Add(depend, temp);
            }
        }
        // ����Ŀ���
        if (!cacheAB.ContainsKey(abName))
        {
            temp = AssetBundle.LoadFromFile(Application.persistentDataPath + "/" + abName);
            cacheAB.Add(abName, temp);
        }
        return cacheAB[abName];

    }

    // �ӻ����л�ȡ�Ѽ��ص���Դ����
    private UnityEngine.Object GetObject(string abName, string resName)
    {
        if(cacheAsset.ContainsKey(abName) && cacheAsset[abName].ContainsKey(resName))
        {
            return cacheAsset[abName][resName];
        }
        return null;
    }

    // ������Դ���ü���
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

        // ����׼���ͷ���Դ�б�
        if (readyToRelease.ContainsKey(abName) && readyToRelease[abName].ContainsKey(resName))
        {
            readyToRelease[abName].Remove(resName);
        } 
    }

    // ������Դ����
    public void DecreaseReferenceCount(string abName, string resName)
    {
        if (!referenceCount.ContainsKey(abName)) Debug.LogError(string.Format("The ab: '{0}' is unloaded ", abName));
        if(!referenceCount[abName].ContainsKey(resName)) Debug.LogError(string.Format("The ab: '{0}' res: '{1}' is unloaded ", abName, resName));
        referenceCount[abName][resName]--;

        // todo ����������ͬ������������ֻ��ab��,û�ж�Ӧ��Դ��

        // ��Դ�ͷ�
        if(referenceCount[abName][resName] <= 0)
        {
            if (!readyToRelease.ContainsKey(abName)) readyToRelease[abName] = new Dictionary<string, float>();
            readyToRelease[abName][resName] = Time.time;
           
        }

    }

    public void UpdateRelease()
    {
        // �Ƿ���Ҫ�ͷ���Դ
        if (readyToRelease.Count <= 0) return;
        // ��ȡ��ȥʱ��
        float nowTime = Time.unscaledTime;
        Dictionary<string, string> temp = new Dictionary<string, string>();
        foreach (var entryAB in readyToRelease)
        {

            foreach(var entryAsset in readyToRelease[entryAB.Key])
            {
                if ((nowTime - entryAsset.Value) < defaultExpireTime) continue;

                // �ͷ���Դ
                temp.Add(entryAB.Key, entryAsset.Key);
                Destroy(cacheAsset[entryAB.Key][entryAsset.Key]);
                cacheAsset[entryAB.Key].Remove(entryAsset.Key);
            }

            // ���ͷ�
            if (referenceCount[entryAB.Key].Count <= 0)
            {
                cacheAB[entryAB.Key].Unload(true);
                cacheAB.Remove(entryAB.Key);
            }
        }



        // ���ͷ���Դ ���������ͷ�
        foreach(var entry in temp)
        {
            readyToRelease[entry.Key].Remove(entry.Value);
        }

    }
   

    // �����Դ�Ļ���
    private void PutAssetInCache(string abName, string resName, Object obj)
    {
        if (!cacheAsset.ContainsKey(abName)) cacheAsset.Add(abName, new Dictionary<string, Object>());
        cacheAsset[abName][resName] = obj;
    }

    // ������Դ mode - 0 ���첽��ʽ���أ� mode - 1 ��ͬ����ʽ����
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

    // ͬ����ʽ������Դ
    private void LoadResSync(string abName, string resName, System.Type type, System.Action<Object> finishedCB)
    {
        LoadAB(abName);
        Object obj = cacheAB[abName].LoadAsset(resName, type);
        PutAssetInCache(abName, resName, obj);
        finishedCB(obj);
    }


    // �첽��ʽ������Դ
    public void LoadResAsync(string abName, string resName, System.Type type, System.Action<Object> finishedCB)
    {
        AssetBundle ab = LoadAB(abName); // ab��ͬ������
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
            // ��ж�ؼ��ص���Դ����
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

