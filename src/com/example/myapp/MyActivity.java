package com.example.myapp;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ShareActionProvider;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

public class MyActivity extends Activity {

    private static final String TAG = "MyActivity";
    private Tencent mTencent;
    private static final String QQ_APP_ID = "222222";

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Button startFloatWindow = (Button) findViewById(R.id.start_float_window);
        mTencent = Tencent.createInstance(QQ_APP_ID, this.getApplicationContext());
        startFloatWindow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View arg0) {
                /*Intent intent = new Intent(MyActivity.this, FloatWindowService.class);
                startService(intent);
                finish();*/

                if(mTencent.isSessionValid()){
                    Log.i(TAG, "qq load session valid return");
                    return;
                }

                mTencent.login(MyActivity.this, "all", new IUiListener() {
                    @Override
                    public void onComplete(Object o) {
                        Log.i(TAG,"qq load complete" + o.toString());
                    }

                    @Override
                    public void onError(UiError uiError) {
                        Log.i(TAG,"qq load error");
                    }

                    @Override
                    public void onCancel() {
                        Log.i(TAG,"qq load cancle");
                    }
                });

            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.main, menu);
        MenuItem shareItem = menu.findItem(R.id.action_share);
        ShareActionProvider provider = (ShareActionProvider) shareItem.getActionProvider();
        provider.setShareIntent(getDefaultIntent());
        return super.onCreateOptionsMenu(menu);
    }

    private Intent getDefaultIntent() {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("image/*");
        return intent;
    }
}
