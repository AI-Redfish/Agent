# 单行/多行代码补全

```
// 写一个工具方法，计算数组平均值
```

以上注释使用tab，会自动生成方法。

```
// 写一个工具方法，计算数组平均值
public static double average(int[] array) {
    int sum = 0;
    for (int i = 0; i < array.length; i++) {
        sum += array[i];
    }
    return (double) sum / array.length;
}
```



支持通过注释，已经有代码片段，自动根据上下文分析你需要的代码，tab后回车即可生成。



另外在类最上方一直按tab，也可完成import自动导入。



# 智能代码重写

已有代码片段

```
public static int[] oddNumbers(int[] array) {
    int[] odd = new int[array.length];
    int index = 0;
    for (int i = 0; i < array.length; i++) {
        if (array[i] % 2 != 0) {
            odd[index++] = array[i];
        }
    }
    return odd;
}
```

补充注释如下：

```
public static int[] oddNumbers(int[] array) {
    int[] odd = new int[array.length];
    int index = 0;
    // 用stream重写
    for (int i = 0; i < array.length; i++) {
        if (array[i] % 2 != 0) {
            odd[index++] = array[i];
        }
    }
    return odd;
}
```

for循环任意位置按tab即可实现重写如下：

```
public static int[] oddNumbers(int[] array) {
    int[] odd = new int[array.length];
    int index = 0;
    // 用stream重写
    return Arrays.stream(array).filter(i -> i % 2 != 0).toArray();
}
```





# 接受/拒绝/部分接受

第一次按tab，触发代码联想（有时不按tab，也会自动触发联想）帮助生成代码。

第二次按tab，接受所有cursor联想生成的代码。

或者esc，拒绝所有生成的代码。或者鼠标点击空白处，手动输入等其他操作也能拒绝联想的代码。



**部分接受**

联想代码生成后，ctrl+右方向键，即可部分接受。

部分接受是一个单词一个单词接受的。

需要在配置中打开(cursor settings中Partial Accepts，不同版本cursor该开关位置不同)。

































