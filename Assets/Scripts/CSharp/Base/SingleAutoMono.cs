using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SingleAutoMono<T> : MonoBehaviour where T: MonoBehaviour
{
    private static T instance;
    public static T Instance
    {
        get
        {
            if(instance == null)
            {
                GameObject obj = new GameObject();
                // �����������Ϊ�ű���
                obj.name = typeof(T).Name;
                // ��Ϊ����ģʽ�����������Ƴ� ������������������
                DontDestroyOnLoad(obj);
                instance = obj.AddComponent<T>();
            }
            return instance;
        }
    }
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
