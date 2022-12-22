using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class ABUpdateMgr : SingleAutoMono<ABUpdateMgr>
{
  
    public static string remotePath = "D:/Test/remoteAddr/";
    // keyΪ���� valueΪMD5��
    // �����ļ���Ϣ ��Զ�̺ͱ���
    private Dictionary<string, string> remoteABInfo = new Dictionary<string, string>();
    private Dictionary<string, string> localABInfo = new Dictionary<string, string>();
    // �����б�
    private List<string> downLoadList = new List<string>();

    private string localVersion;
    private string remoteVersion;


    public void CheckABUpdate()
    {   

        // ��һ������ʱ��ԴǨ��
        ResCopy();


        // ��ȡԶ�̺ͱ��ذ汾��
        GetRemoteVersion();
        GetLocalVersion();
        Debug.Log("���ذ汾�ţ�" + localVersion + " Զ�̰汾�ţ�" + remoteVersion);

        // �Ƚϰ汾���ж��Ƿ���Ҫ����
        if (!IsNeedUpdate()) return;

        Debug.Log("��Ҫ����");
        remoteABInfo.Clear();
        localABInfo.Clear();
        downLoadList.Clear();

        // ��ȡԶ�̸����ļ�
        LoadRemoteUpdateFile();

        // ��ȡ���ظ����ļ�
        LoadLocalUpdateFile();

        // �Ƚ��ж��Ƿ���Ҫ����
        foreach(var entry in remoteABInfo)
        {   
            // �µ�AB��
            if (!localABInfo.ContainsKey(entry.Key))
            {
                downLoadList.Add(entry.Key);
            }
            else if(localABInfo[entry.Key] != remoteABInfo[entry.Key])
            {
                // MD5�벻ͬ
                downLoadList.Add(entry.Key);
            }
            
        }

        // ���ذ� �����а汾��Ϣ����
        DoUpdate();
    }
   

    // ����Դ��ֻ��Ŀ¼���Ƶ��ɶ�дĿ¼
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
            Debug.Log("��һ����������Դ��ֻ��Ŀ¼���Ƶ��ɶ�дĿ¼");
        }
        
    }


    public bool IsNeedUpdate()
    {
        if (remoteVersion != localVersion) return true;
        return false;
    }

    private void DoUpdate()
    {   
        // �����°�
        foreach(string name in downLoadList)
        {
            DownLoadRemoteFile(name, Application.persistentDataPath + "/" + name);
        }

        // ������ɺ� ����ʱ�����ļ��滻���ظ����ļ� ͬʱ���±��ذ汾�ļ�
        File.Delete(Application.persistentDataPath + "/update.txt");
        FileInfo f1 = new FileInfo(Application.persistentDataPath + "/update_temp.txt");
        f1.MoveTo(Application.persistentDataPath + "/update.txt");

        localVersion = remoteVersion;
        // ����д��
        File.WriteAllText(Application.persistentDataPath + "/version.txt", "game_" + localVersion);

    }
   

    // ��ȡ�����ļ���Ϣ
    private void ReadABInfoInDict(string filePath, Dictionary<string, string> dict)
    {
        // ��ȡ�汾�ļ���Ϣ
        string info = File.ReadAllText(filePath);
        string[] strs = info.Split(' ');
        string[] infos = null;
        for (int i = 0; i < strs.Length; i++)
        {
            infos = strs[i].Split('_');
            dict.Add(infos[0], infos[1]);
        }
    }

    // ����Զ�̸����ļ�
    public void LoadRemoteUpdateFile()
    {   
        // �����ص����� ������ʱ�ļ�����
        DownLoadRemoteFile("update.txt", Application.persistentDataPath + "/update_temp.txt");


        // ��ȡԶ�̸����ļ���Ϣ
        ReadABInfoInDict(Application.persistentDataPath + "/update_temp.txt", remoteABInfo);
    }

    public void LoadLocalUpdateFile()
    {   
        // ��ȡ���ظ����ļ���Ϣ
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
            Debug.Log("���سɹ�");
        }
        catch (Exception ex)
        {
            Debug.Log("����ʧ��" + ex.Message);
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
