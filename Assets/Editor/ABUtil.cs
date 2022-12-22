using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using Object = UnityEngine.Object;
using System.Security.Cryptography;

public class ABUtil : Editor
{
    public static string path = "Assets/ArtRes/PC";
    public static string remotePath = "D:/Test/remoteAddr/";

    [MenuItem("Tools/CreateAssetBundle")]
    public static void CreatePCAB()
    {
        if (!Directory.Exists(path)){
            Directory.CreateDirectory(path);
        }
        BuildPipeline.BuildAssetBundles(path, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows64);
        AssetDatabase.Refresh();
    }

    [MenuItem("Tools/CreateABUpdateAndVersionFile")]
    public static void CreateABUpdateAndVersionFile()
    {
        DirectoryInfo directory = Directory.CreateDirectory(path);
        FileInfo[] fileInfos = directory.GetFiles();

        string ABInfo = "";
        string ABVersion = "";

        foreach (FileInfo info in fileInfos)
        {   
            // 根据后缀判断是否AB包
            if(info.Extension == "")
            {
                ABInfo += info.Name + "_" + BuildFileMd5(info.FullName);
                ABInfo += " ";
            }
        }
        ABInfo = ABInfo.Substring(0, ABInfo.Length - 1);
        ABVersion = "game" + "_" + System.DateTime.Now.ToString("d");
        File.WriteAllText(path + "/update.txt", ABInfo);
        File.WriteAllText(path + "/version.txt", ABVersion);
        AssetDatabase.Refresh();
    }

    [MenuItem("Tools/UploadABAndUpdateAndVersionFile")]
    public static void UploadABAndUpdateAndVersionFile()
    {
        DirectoryInfo directory = Directory.CreateDirectory(path);
        FileInfo[] fileInfos = directory.GetFiles();

        foreach (FileInfo info in fileInfos)
        { 
        
            if (info.Extension == "" || info.Extension == ".txt")
            {
                UpLoadFile(info.FullName, info.Name);
            }
        }
    }

    [MenuItem("Tools/MoveABToStreamingAssets")]
    public static void MoveABToStreamingAssets()
    {
        // 获取选中的资产
        Object[] selectedAsset = Selection.GetFiltered(typeof(object), SelectionMode.DeepAssets);

        if (selectedAsset.Length == 0)
        {
            return;
        }
        else
        {
            string ABInfo = "";
            string ABVersion = "";
            foreach (Object asset in selectedAsset)
            {
                string assetPath = AssetDatabase.GetAssetPath(asset);
                string fileName = assetPath.Substring(assetPath.LastIndexOf('/'));
                AssetDatabase.CopyAsset(assetPath, "Assets/StreamingAssets" + fileName);
                FileInfo fileInfo = new FileInfo(Application.streamingAssetsPath + fileName);
                if(fileInfo.Extension == "") // manifest文件不记录
                {
                    ABInfo += fileInfo.Name + "_" + BuildFileMd5(Application.streamingAssetsPath + fileName);
                    ABInfo += " ";
                }
                
            }
            ABInfo = ABInfo.Substring(0, ABInfo.Length - 1);
            ABVersion = "game" + "_" + System.DateTime.Now.ToString("d");
            File.WriteAllText(Application.streamingAssetsPath + "/update.txt", ABInfo);
            File.WriteAllText(Application.streamingAssetsPath + "/version.txt", ABVersion);
            AssetDatabase.Refresh();
        }
    }

    public static string BuildFileMd5(string filePath)
    {
        string fileMd5 = "";
        try
        {
             using (FileStream fs = File.OpenRead(filePath))
            {
                MD5 md5 = MD5.Create();
                byte[] fileMd5Bytes = md5.ComputeHash(fs);  // 计算FileStream 对象的哈希值
                fileMd5 = System.BitConverter.ToString(fileMd5Bytes).Replace("-", "").ToLower();
            }

        }catch(Exception ex)
        {
            Debug.LogError(ex);
        }
        return fileMd5;
    }

    // 这里只是复制到本地的其他路径
    private static void UpLoadFile(string filePath, string fileName)
    {
        try
        {
            FileStream tar = new FileStream(remotePath + fileName, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
            
            using (FileStream src = File.OpenRead(filePath))
            {
                byte[] bytes = new byte[2048];
                int length = src.Read(bytes, 0, bytes.Length);
                while (length != 0)
                {
                    tar.Write(bytes, 0, length);
                    length = src.Read(bytes, 0, bytes.Length);
                    
                }
                
                src.Close();
                tar.Flush();
                tar.Close();
            }
            Debug.Log("上传成功");
        }catch(Exception ex)
        {
            Debug.Log("上传失败" + ex.Message);
        }
    }
}
