using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(Application.persistentDataPath);
        // 已启动检查是否需要更新
        // ABUpdateMgr.Instance.CheckABUpdate();
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
