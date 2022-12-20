using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ABUtil : Editor
{
    [MenuItem("Tools/CreateAssetBundle")]
    public static void CreatePCAB()
    {
        string path = "Assets/ArtRes/AB";
        if (!Directory.Exists(path)){
            Directory.CreateDirectory(path);
        }
        BuildPipeline.BuildAssetBundles(path, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows64);
        UnityEngine.Debug.Log("win finish create ab");
    }
}
