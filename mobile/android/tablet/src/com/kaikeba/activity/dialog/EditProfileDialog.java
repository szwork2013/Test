package com.kaikeba.activity.dialog;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.Toast;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.UsersAPI;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;

import java.io.File;
import java.io.IOException;


public class EditProfileDialog extends SignupDialog {

    Bitmap mbitmap;
    private ProgressBar load_progressBar;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            load_progressBar.setVisibility(View.INVISIBLE);
            switch (msg.what) {
                case 0:
                    Toast.makeText(selfContext, "图片处理有误，请检查图片后重新提交。",
                            Toast.LENGTH_LONG).show();
                    break;
                case 1:
                    load_progressBar.setVisibility(View.INVISIBLE);
                    Toast.makeText(selfContext, "修改成功！",
                            Toast.LENGTH_SHORT).show();
                    ((EditProfileDialog) selfContext).finish();
                    MainActivity.getMainActivity().getMainNavFragment().
                            changeUserInMainNav(API.getAPI().getUserObject().getShortName(), API.getAPI().getUserObject().getAvatarUrl());
                    break;
                case 2:
                    load_progressBar.setVisibility(View.INVISIBLE);
                default:
                    break;
            }
        }

        ;
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Bundle bundle = new Bundle();
        bundle.putInt("View", R.layout.dlg_edituser);
        super.onCreate(bundle);
        load_progressBar = (ProgressBar) findViewById(R.id.load_progressBar);
        selfContext = this;

        mbitmap = ImgLoaderUtil.getLoader().loadImg(API.getAPI().getUserObject().getAvatarUrl(), new ImgLoaderUtil.ImgCallback() {

            @Override
            public void refresh(Bitmap bitmap) {
                imgAvatar.setBackgroundDrawable(new BitmapDrawable(getResources(), bitmap));
                if (bitmap != null) {
                    mbitmap = bitmap;
                }
            }
        }, handler);

        if (mbitmap != null) {
            imgAvatar.setBackgroundDrawable(new BitmapDrawable(getResources(), mbitmap));
        }

        etEmail.setText(API.getAPI().getUserObject().getLoginId());

        etNickName.setText(API.getAPI().getUserObject().getShortName());


        btnAction.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if (!Constants.NET_IS_SUCCESS) {
                    Toast.makeText(selfContext, "网络未连接",
                            Toast.LENGTH_SHORT).show();
                    return;
                }
                load_progressBar.setVisibility(View.VISIBLE);
                final String email = etEmail.getText().toString();
                final String nickname = etNickName.getText().toString();
                new Thread() {
                    public void run() {
                        User userEdited = null;
                        try {
                            checkUserNameInput(nickname);
                            userAvatarFile = new File(Environment.getExternalStorageDirectory() + File.separator + "imageCache", userAvatarFileName);
                            /*try {
                                if (photo == null) {
                            		userAvatarFile = ImgLoaderUtil.writePic2SDCard(mbitmap, userAvatarFileName);
                            	}
                            	else {
                            		userAvatarFile = ImgLoaderUtil.writePic2SDCard(photo, userAvatarFileName);
                            	}
							} catch (Exception e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}*/
                            userEdited = UsersAPI.editUser(API.getAPI().getUserObject().getId().toString(), nickname, userAvatarFile);
                        } catch (final DibitsExceptionC e) {
                            tv_errorinfo.post(new Runnable() {

                                @Override
                                public void run() {
                                    // TODO Auto-generated method stub
                                    tv_errorinfo.setText(e.getMessageX());
                                }
                            });
                            handler.sendEmptyMessage(2);
                            return;
                        } catch (IOException e) {
                            handler.sendEmptyMessage(0);
                            e.printStackTrace();
                            return;
                        }
                        User user = API.getAPI().getUserObject();
                        user.setShortName(nickname);
                        user.setAvatarURL(userEdited.getAvatarUrl());
                        API.getAPI().writeUserInfo2SP(user, null);
                        handler.sendEmptyMessage(1);
                    }

                    ;
                }.start();
            }
        });
    }
}
