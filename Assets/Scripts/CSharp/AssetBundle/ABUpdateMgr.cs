using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class ABUpdateMgr : SingleAutoMono<ABUpdateMgr>
{
  
    public static string remotePath = "D:/Test/remoteAddr/";
    // key为包名 value为MD5码
    // 更新文件信息 分远程和本地
    private Dictionary<string, string> remoteABInfo = new Dictionary<string, string>();
    private Dictionary<string, string> localABInfo = new Dictionary<string, string>();
    // 下载列表
    private List<string> downLoadList = new List<string>();

    private string localVersion;
    private string remoteVersion;


    public void CheckABUpdate()
    {   

        // 第一次启动时资源迁移
        ResCopy();


        // 获取远程和本地版本号
        GetRemoteVersion();
        GetLocalVersion();
        Debug.Log("本地版本号：" + localVersion + " 远程版本号：" + remoteVersion);

        // 比较版本号判断是否需要更新
        if (!IsNeedUpdate()) return;

        Debug.Log("需要更新");
        remoteABInfo.Clear();
        localABInfo.Clear();
        downLoadList.Clear();

        // 读取远程更新文件
        LoadRemoteUpdateFile();

        // 读取本地更新文件
        LoadLocalUpdateFile();

        // 比较判断是否需要更新
        foreach(var entry in remoteABInfo)
        {   
            // 新的AB包
            if (!localABInfo.ContainsKey(entry.Key))
            {
                downLoadList.Add(entry.Key);
            }
            else if(localABInfo[entry.Key] != remoteABInfo[entry.Key])
            {
                // MD5码不同
                downLoadList.Add(entry.Key);
            }
            
        }

        // 下载包 并进行版本信息更新
        DoUpdate();
    }
   

    // 将资源从只读目录复制到可读写目录
    public void ResCopy()
    {
        DirectoryInfo tar = Directory.CreateDirectory(Application.persistentDataPath);
        DirectoryInfo sour = Directory.CreateDirectory(Application.streamingAssetsPath);
        if (tar.GetFiles().Length == 0)
        {
            foreach (FileInfo file in sour.GetFiles())
            {
                File.Copy(file.FullName, tar.FullName + "/" + file.Name, true);
            }
            Debug.Log("第一次启动，资源从只读目录复制到可读写目录");
        }
        
    }


    public bool IsNeedUpdate()
    {
        if (remoteVersion != localVersion) return true;
        return false;
    }

    private void DoUpdate()
    {   
        // 下载新包
        foreach(string name in downLoadList)
        {
            DownLoadRemoteFile(name, Application.persistentDataPath + "/" + name);
        }

        // 下载完成后 用临时更新文件替换本地更新文件 同时更新本地版本文件
        File.Delete(Application.persistentDataPath + "/update.txt");
        FileInfo f1 = new FileInfo(Application.persistentDataPath + "/update_temp.txt");
        f1.MoveTo(Application.persistentDataPath + "/update.txt");

        localVersion = remoteVersion;
        // 覆盖写入
        File.WriteAllText(Application.persistentDataPath + "/version.txt", "game_" + localVersion);

    }
   

    // 读取更新文件信息
    private void ReadABInfoInDict(string filePath, Dictionary<string, string> dict)
    {
        // 读取版本文件信息
        string info = File.ReadAllText(filePath);
        string[] strs = info.Split(' ');
        string[] infos = null;
        for (int i = 0; i < strs.Length; i++)
        {
            infos = strs[i].Split('_');
            dict.Add(infos[0], infos[1]);
        }
    }

    // 加载远程更新文件
    public void LoadRemoteUpdateFile()
    {   
        // 先下载到本地 并用临时文件保存
        DownLoadRemoteFile("update.txt", Application.persistentDataPath + "/update_temp.txt");


        // 读取远程更新文件信息
        ReadABInfoInDict(Application.persistentDataPath + "/update_temp.txt", remoteABInfo);
    }

    public void LoadLocalUpdateFile()
    {   
        // 读取本地更新文件信息
        ReadABInfoInDict(Application.persistentDataPath + "/update.txt", localABInfo);
    }

    private void DownLoadRemoteFile(string fileName, string localPath)
    {
        try
        {
            FileStream tar = new FileStream( localPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);

            using (FileStream src = File.OpenRead(remotePath +  fileName))
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
            Debug.Log("下载成功");
        }
        catch (Exception ex)
        {
            Debug.Log("下载失败" + ex.Message);
        }
    }

    public void GetRemoteVersion()
    {
        string info = File.ReadAllText(remotePath + "version.txt");
        remoteVersion =  info.Split('_')[1];
      
    }

    public void GetLocalVersion()
    {
        string info = File.ReadAllText(Application.persistentDataPath + "/version.txt");
        localVersion = info.Split('_')[1];
    }
}
