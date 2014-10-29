package com.example.myapp.test2;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-9-26.
 */
public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main2);
        String text = "在之前的一篇博客里介绍过activity间动画跳转的问题，但是真正做软件发现并不能满足我们的要求，" +
                "因为使用overridePendingTransition(int enterAnim, intexitAnim)这个函数只能实现进入另一个activity的动画，" +
                "当另一个activity退出时，还是使用的系统动画。" +
                "所以在这里讲一下怎么设置所有activity的动画跳转和退出跳转。其实有些软件已经这样做了，比如我们都比较熟悉的大众点评网。\n" +
                "\n" +
                "         下面我们通过一个实例来看一下怎么实现所有activity动画跳转，这里我们不妨就模仿下大众点评网activity的动画跳转。";
        CollapsibleTextView collapseTv = (CollapsibleTextView) findViewById(R.id.collapsible_textview);
        collapseTv.setDesc( text , TextView.BufferType.NORMAL);
    }
}
