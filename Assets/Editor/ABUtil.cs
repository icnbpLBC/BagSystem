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
            // 根据后缀判断是否AB包
            if(info.Extension == "")
            {   
                // 每个ab包资源均为 包名_日期
                abVersionInfo += info.Name + "_" + System.DateTime.Now.ToString("d");
                // 空格分割
                abVersionInfo += " ";
            }
        }
        // 去掉最后的分隔符
        abVersionInfo = abVersionInfo.Substring(0, abVersionInfo.Length - 1);
        // 写入版本文件
        File.WriteAllText(path + "/ab_version.txt", abVersionInfo);
    }
}
