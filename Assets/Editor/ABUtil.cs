using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ABUtil : Editor
{
    static string path = "Assets/ArtRes/AB";

    [MenuItem("Tools/CreateAssetBundle")]
    public static void CreatePCAB()
    {
        if (!Directory.Exists(path)){
            Directory.CreateDirectory(path);
        }
        BuildPipeline.BuildAssetBundles(path, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows64);
        UnityEngine.Debug.Log("win finish create ab");
    }

    [MenuItem("Tools/CreateABVersionFile")]
    public static void CreateABVersionFile()
    {
        DirectoryInfo directory = Directory.CreateDirectory(path);
        FileInfo[] fileInfos = directory.GetFiles();
        string abVersionInfo = "";

        foreach(FileInfo info in fileInfos)
        {   
            // ���ݺ�׺�ж��Ƿ�AB��
            if(info.Extension == "")
            {   
                // ÿ��ab����Դ��Ϊ ����_����
                abVersionInfo += info.Name + "_" + System.DateTime.Now.ToString("d");
                // �ո�ָ�
                abVersionInfo += " ";
            }
        }
        // ȥ�����ķָ���
        abVersionInfo = abVersionInfo.Substring(0, abVersionInfo.Length - 1);
        // д��汾�ļ�
        File.WriteAllText(path + "/ab_version.txt", abVersionInfo);
    }
}
