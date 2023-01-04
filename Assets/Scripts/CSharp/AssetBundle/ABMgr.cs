using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
[LuaCallCSharp]
public class ABMgr : SingleAutoMono<ABMgr>
{
    // ����AB�� keyΪab���� valueΪab��
    private Dictionary<string, AssetBundle> cacheAB = new Dictionary<string, AssetBundle>();
    // ��¼���ü���
    private Dictionary<string, Dictionary<string, int>> referenceCount = new Dictionary<string, Dictionary<string, int>>();
    // ������Դ
    private Dictionary<string, Dictionary<string, Object>> cacheAsset = new Dictionary<string, Dictionary<string, Object>>();

    // ����
    private AssetBundle mainAB = null;
    // ��������
    private AssetBundleManifest manifest = null;
    // Start is called before the first frame update

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
    private Object GetObject(string abName, string resName)
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
    }

    // ������Դ����
    public void DecreaseReferenceCount(string abName, string resName)
    {
        if (!referenceCount.ContainsKey(abName)) Debug.LogError(string.Format("The ab: '{0}' is unloaded ", abName));
        if(!referenceCount[abName].ContainsKey(resName)) Debug.LogError(string.Format("The ab: '{0}' res: '{1}' is unloaded ", abName, resName));
        referenceCount[abName][resName]--;
    }

    // �����Դ�Ļ��� todo ��������
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
