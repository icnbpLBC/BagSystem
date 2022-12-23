using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

// xLua会生成这个类型的适配代码
[LuaCallCSharp]
public static class ProjectConstantData
{   
    // 物品名数组 用于从图集中加载对应物品图像
    public static string[] ItemsNameArray = new string[]
    {
         "EquipIcon1",
        "EquipIcon2",
        "EquipIcon3",
        "EquipIcon4",
        "EquipIcon5",
        "EquipIcon6",
        "GemIcon1",
        "GemIcon2",
        "GemIcon3",
        "GemIcon4",
        "GemIcon5",
        "GemIcon6",
        "GemIcon7",
        "ItemIcon1",
        "ItemIcon2",
        "ItemIcon3",
        "ItemIcon4",
    };
}
