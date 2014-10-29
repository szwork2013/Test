package com.kaikeba.activity.dialog;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;
import com.kaikeba.common.api.UsersAPI;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.common.util.Syntax;
import com.kaikeba.phone.R;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;


public class SignupDialog extends Activity {

    public static final int NONE = 0;
    public static final int PHOTOHRAPH = 1;// 拍照
    public static final int PHOTOZOOM = 2; // 缩放
    public static final int PHOTORESOULT = 3;// 结果
    public static final String IMAGE_UNSPECIFIED = "image/*";
    static String userAvatarFileName = "userTempAvatar.png";
    private static File tempFile;
    public Bitmap photo;
    public TextView tv_errorinfo;
    Context selfContext;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
//				load_progressBar.setVisibility(View.GONE);
//				Toast.makeText(selfContext,
//						((DibitsExceptionC) msg.obj).getMessageX(),
//						Toast.LENGTH_LONG).show();
                    if (((DibitsExceptionC) msg.obj).getMessageX().contains("Email error")) {
                        tv_errorinfo.setText("邮箱已经被注册，请重新填写邮箱！");
                        break;
                    } else if (((DibitsExceptionC) msg.obj).getMessageX().contains("服务器错误，泛指，不知道具体错误")) {
                        tv_errorinfo.setText("邮箱已经被注册，请重新填写邮箱！");
                        break;
                    } else if (((DibitsExceptionC) msg.obj).getMessageX().contains("learn.kaikeba.com")) {
                        tv_errorinfo.setText("当前网络不可用，无法注册");
                        break;
                    }
                    tv_errorinfo.setText(((DibitsExceptionC) msg.obj).getMessageX());
                    break;
                case 1:
//				load_progressBar.setVisibility(View.GONE);
                    Toast.makeText(selfContext, "注册成功！请登录~（已授权客户端）",
                            Toast.LENGTH_SHORT).show();
                    Intent intent = new Intent(selfContext, WebViewDialog.class);
                    selfContext.startActivity(intent);
                    finish();
                    break;
                default:
                    break;
            }
        }

        ;
    };
    ImageView imgAvatar;
    TextView btnAddAvatar;
    EditText etEmail;
    EditText etPassword;
    EditText etNickName;
    //    EditText        etRealName;
    TextView btnAction;
    TextView tvPx;
    //    TextView        txtInstructorName;
    PopupWindow popup;
    File userAvatarFile;
    private ImageView iv_head_error;
    private ImageView iv_email_error;
    private ImageView iv_password_error;
    private ImageView iv_nil_error;
    private View.OnFocusChangeListener emailFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                try {
                    checkEmailInput(((EditText) v).getText().toString());
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                }
            } else {
                int i = 0;
            }
        }
    };

    private View.OnFocusChangeListener pwdFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                try {
                    checkPasswordInput(((EditText) v).getText().toString());
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                }
            }
        }
    };

    private View.OnFocusChangeListener userNameFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                try {
                    checkUserNameInput(((EditText) v).getText().toString());
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                }
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            setContentView(R.layout.regist);
        } else {
            setContentView(savedInstanceState.getInt("View"));
        }
        TextView tv_signin = (TextView) findViewById(R.id.tv_signin);
        selfContext = this;
        imgAvatar = (ImageView) findViewById(R.id.imgSignupAvatar);
        btnAddAvatar = (TextView) findViewById(R.id.add_avatar);
        etEmail = (EditText) findViewById(R.id.et_regist_email);
        etPassword = (EditText) findViewById(R.id.et_regist_password);
        etNickName = (EditText) findViewById(R.id.et_nil_truename);
        etEmail.setOnFocusChangeListener(emailFocusListener);
        if (etPassword != null) {
            etPassword.setOnFocusChangeListener(pwdFocusListener);
        }
        etNickName.setOnFocusChangeListener(userNameFocusListener);
        btnAction = (TextView) findViewById(R.id.tv_signup);
        tvPx = (TextView) findViewById(R.id.txtPx);
        tv_errorinfo = (TextView) findViewById(R.id.tv_errorinfo);
        iv_head_error = (ImageView) findViewById(R.id.iv_head_error);
        iv_email_error = (ImageView) findViewById(R.id.iv_email_error);
        iv_password_error = (ImageView) findViewById(R.id.iv_password_error);
        iv_nil_error = (ImageView) findViewById(R.id.iv_nil_error);

        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            tempFile = new File(Environment.getExternalStorageDirectory(), userAvatarFileName);
        } else {
            tempFile = new File(getFilesDir(), userAvatarFileName);
        }

        btnAddAvatar.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if (popup == null) {
                    popup = new PopupWindow(getLayoutInflater().inflate(R.layout.popup_window, null),
                            android.view.ViewGroup.LayoutParams.WRAP_CONTENT, android.view.ViewGroup.LayoutParams.WRAP_CONTENT);
                    ImageButton btnAddFromAlbum = (ImageButton) popup.getContentView().findViewById(R.id.btnAddFromAlbum);
                    ImageButton btnAddFromCamera = (ImageButton) popup.getContentView().findViewById(R.id.btnAddFromCamera);

                    btnAddFromAlbum.setOnClickListener(new View.OnClickListener() {

                        @Override
                        public void onClick(View v) {
//                            Toast.makeText(selfContext, "FromAlbum",
//                                    Toast.LENGTH_SHORT).show();
//                            Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                            Intent intent = new Intent(Intent.ACTION_PICK, null);
                            intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                    IMAGE_UNSPECIFIED);
                            startActivityForResult(intent, PHOTOZOOM);
                        }
                    });

                    btnAddFromCamera.setOnClickListener(new View.OnClickListener() {

                        @Override
                        public void onClick(View v) {
                            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                            intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(tempFile));
                            startActivityForResult(intent, PHOTOHRAPH);
                        }
                    });
                }
                popup.showAsDropDown(tvPx, 0, -10);
            }
        });

        btnAction.setOnClickListener(new View.OnClickListener() {
            //TODO
            @Override
            public void onClick(View v) {
                final String email = etEmail.getText().toString();
                final String password = etPassword.getText().toString();
                final String nickname = etNickName.getText().toString();
                final String confirmed_at = DateUtils.getCurrentTime();
                try {
                    checkInput(email, password, nickname);
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                    return;
                }
                new Thread() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        try {
                            UsersAPI.signupUser(nickname, email, password, confirmed_at, "mobile", userAvatarFile);
                            SignupDialog.this.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Toast.makeText(SignupDialog.this, "正在注册，请稍后.....", Toast.LENGTH_SHORT).show();
                                }
                            });
                            handler.sendEmptyMessage(1);
                        } catch (DibitsExceptionC e) {
                            e.printStackTrace();
                            Message msg = Message.obtain();
                            msg.obj = e;
                            msg.what = 0;
                            handler.sendMessage(msg);
                            return;
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }.start();
            }
        });
        if (tv_signin != null) {
            tv_signin.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View v) {
                    // TODO Auto-generated method stub
                    Intent intent = new Intent(SignupDialog.this, WebViewDialog.class);
                    startActivity(intent);
                    finish();
                }
            });
        }
    }

    private void setError(final ImageView v) {
        if (v == null) {
            return;
        }
        v.post(new Runnable() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                v.setVisibility(View.VISIBLE);
                v.setBackground(getResources().getDrawable(R.drawable.validate_false));
            }
        });
    }

    private void setTrue(final ImageView v) {
        if (v == null) {
            return;
        }
        v.post(new Runnable() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                v.setVisibility(View.VISIBLE);
                v.setBackground(getResources().getDrawable(R.drawable.validate_true));
            }
        });
    }

    private void printError(ImageView v, String msg) throws DibitsExceptionC {
        setError(v);
        throw new DibitsExceptionC(DEC.Syntax.USER_EMAIL, msg);
    }

    protected void checkEmailInput(String email) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserEmailErrorInfo(email);
        switch (checkErrorInput) {
            case EMAIL_ERROR_EMPTY:
                printError(iv_email_error, "邮箱不能为空！");
                break;
            case EMAIL_ERROR_ILLEGAL:
                printError(iv_email_error, "邮箱格式错误，请输入正确的邮箱！");
                break;
            case SUCCESS:
                setTrue(iv_email_error);
                tv_errorinfo.setText("");
                break;
            default:
                break;
        }
    }

    protected void checkPasswordInput(String password) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserPasswordErrorInfo(password);
        switch (checkErrorInput) {
            case PASSWORD_ERROR_EMPTY:
                printError(iv_password_error, "密码不能为空！");
                break;
            case PASSWORD_ERROR_LENGTH:
                printError(iv_password_error, "密码长度必须为6-16位！");
                break;
            case SUCCESS:
                setTrue(iv_password_error);
                tv_errorinfo.setText("");
                break;
            default:
                break;
        }
    }

    protected void checkUserNameInput(String userName) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserNameErrorInfo(userName);
        switch (checkErrorInput) {
            case USER_ERROR_EMPTY:
                printError(iv_nil_error, "用户不能为空！");
                break;
            case USER_ERROR_LENGTH:
                printError(iv_nil_error, "用户名长度必须为3-18位！");
                break;
            case USER_ERROR_ILLEGAL:
                printError(iv_nil_error, "用户名不规范：用户名由中英文、数字、下划线组成！");
                break;
            case SUCCESS:
                setTrue(iv_nil_error);
                tv_errorinfo.setText("");
                break;
            default:
                break;
        }
    }

    protected void checkInput(final String email, String password, String userName) throws DibitsExceptionC {

        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserEmailErrorInfo(email);
        if (checkErrorInput != Syntax.ERROR_INFO.SUCCESS) {
            printError(iv_email_error, Syntax.ERROR_INFO.getType(checkErrorInput));
        } else {
            checkErrorInput = Syntax.getUserPasswordErrorInfo(password);
            if (checkErrorInput != Syntax.ERROR_INFO.SUCCESS) {
                printError(iv_password_error, Syntax.ERROR_INFO.getType(checkErrorInput));
            } else {
                checkErrorInput = Syntax.getUserNameErrorInfo(userName);
                if (checkErrorInput != Syntax.ERROR_INFO.SUCCESS) {
                    printError(iv_nil_error, Syntax.ERROR_INFO.getType(checkErrorInput));
                }
            }
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (popup != null) {
            if (popup.isShowing()) {
                popup.dismiss();
            }
        }
        InputMethodManager imm = (InputMethodManager) this.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(this.getCurrentFocus().getWindowToken(), 0);
//        if (imm.isActive()) {
//        	return imm.hideSoftInputFromWindow(this.getCurrentFocus().getWindowToken(), 0);
//        }
        return super.onTouchEvent(event);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (popup != null) {
            if (popup.isShowing()) {
                popup.dismiss();
            }
        }

        //   if (resultCode == NONE)
        //      return;
        // 拍照
        if (requestCode == PHOTOHRAPH) {
            // 设置文件保存路径这里放在跟目录下
            //       userAvatarFile = new File(Environment.getExternalStorageDirectory()
            //              + userAvatarFileName);
            //       System.out.println("------------------------" + userAvatarFile.getPath());
            userAvatarFile = tempFile;
            startPhotoZoom(Uri.fromFile(tempFile));
        }

        if (data == null)
            return;

        // 读取相册缩放图片
        if (requestCode == PHOTOZOOM) {
            startPhotoZoom(data.getData());
        }
        // 处理结果
        if (requestCode == PHOTORESOULT) {
            Bundle extras = data.getExtras();
            if (extras != null) {
                if (photo != null) {
                    photo.recycle();
                    photo = null;
                }
                photo = extras.getParcelable("data");

                if (photo == null) {
                    String filePath = extras.getString("filePath");
                    if (filePath != null)
                        photo = BitmapFactory.decodeFile(filePath);
                }

                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub

                        iv_head_error.setVisibility(View.VISIBLE);
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        photo.compress(Bitmap.CompressFormat.PNG, 100, stream);// (0
                        // -
                        // 100)压缩文件
                        try {
                            userAvatarFile = ImgLoaderUtil.writePic2SDCard(
                                    photo, userAvatarFileName);
                        } catch (Exception e) {
                            e.printStackTrace();
                            iv_head_error.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_false));
                            Toast.makeText(selfContext, "图片获取有误，请重试。",
                                    Toast.LENGTH_SHORT).show();
                            return;
                        }
                        // imgAvatar.setImageBitmap(photo);
                        imgAvatar.setBackground(new BitmapDrawable(
                                getResources(), photo));
                        iv_head_error.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_true));

                    }
                });
            }

        }

        super.onActivityResult(requestCode, resultCode, data);
    }

    public void startPhotoZoom(Uri uri) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, IMAGE_UNSPECIFIED);
        intent.putExtra("crop", "true");
        // aspectX aspectY 是宽高的比例
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        // outputX outputY 是裁剪图片宽高
        intent.putExtra("outputX", 180);
        intent.putExtra("outputY", 180);
        intent.putExtra("scale", true);
        intent.putExtra("scaleUpIfNeeded", true);
        intent.putExtra("return-data", true);
        intent.putExtra("noFaceDetection", true);
        startActivityForResult(intent, PHOTORESOULT);
    }
}
