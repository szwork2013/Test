package com.kaikeba.activity;

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
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;
import android.widget.AdapterView.OnItemSelectedListener;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.UsersAPI;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.ErrorInfo;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.entity.UserLoginInfo;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.controller.listener.SocializeListeners;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

//import com.sina.weibo.sdk.auth.WeiboAuth;

public class RegistActivity extends BaseActivity {
    public static final int NONE = 0;
    public static final int PHOTOHRAPH = 1;// 拍照
    public static final int PHOTOZOOM = 2; // 缩放
    public static final int PHOTORESOULT = 3;// 结果
    public static final String IMAGE_UNSPECIFIED = "image/*";
    private final static String tag = "RegistActivity";
    private static final String[] selectType = {"请选择", "相册", "拍照"};
    static String userAvatarFileName = "userTempAvatar.png";
    boolean isChoose = false;
    String emailF;
    String userName;
    private Context selfContext;
    private ImageView imgAvatar;
    //	private ImageView ivRegist;
    private ImageView iv_regist_back;
    //	private TextView btnAddAvatar;
    private EditText etEmail;
    private EditText etPassword;
    private EditText etNickName;
    private TextView btnAction;
    private File userAvatarFile;
    private TextView tv_errorinfo;
    //	private TextView tv_signin;
    private ProgressBar load_progressBar;
    private Spinner spinner;
    private ArrayAdapter<String> adapter;
    private HashMap<String, String> actionmap;
    private boolean error_email_repet = false;
    private boolean error_username_repet = false;
    private View.OnFocusChangeListener emailFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(final View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                error_username_repet = false;
                emailF = ((EditText) v).getText().toString();
                if (emailF != null && !emailF.equals("")) {
                    new Thread() {
                        @Override
                        public void run() {
                            try {
                                UsersAPI.check4Repet(username, emailF);
                            } catch (DibitsExceptionC e) {
                                e.printStackTrace();
                                Message msg = Message.obtain();
                                msg.obj = e;
                                msg.what = 0;
                                handler.sendMessage(msg);
                            }
                        }
                    }.start();
                }
                try {
                    checkEmailInput(emailF);
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
    private View.OnFocusChangeListener userNameFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(final View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                error_username_repet = false;
                userName = ((EditText) v).getText().toString();
                if (userName != null && !userName.equals("")) {
                    new Thread() {
                        @Override
                        public void run() {
                            try {
                                UsersAPI.check4Repet(userName, email);
                            } catch (DibitsExceptionC e) {
                                e.printStackTrace();
                                Message msg = Message.obtain();
                                msg.obj = e;
                                msg.what = 0;
                                handler.sendMessage(msg);
                            }
                        }
                    }.start();
                }
                try {
                    checkUserNameInput(userName);
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
    private Bitmap photo;
    //	private ImageView iv_head_error;
    private ImageView iv_email_error;
    private ImageView iv_password_error;
    private ImageView iv_nil_error;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    KKDialog.getInstance().dismiss();
                    load_progressBar.setVisibility(View.GONE);
                    if (((DibitsExceptionC) msg.obj).getMessageX().contains("Email error")) {
                        tv_errorinfo.setText("邮箱已经被注册，请重新填写邮箱！");
                        setError(iv_email_error);
                        error_email_repet = true;
                        break;
                    } else if (((DibitsExceptionC) msg.obj).getMessageX().contains("UserName error")) {
                        tv_errorinfo.setText("用户名已经被注册，请重新填写用户名！");
                        setError(iv_nil_error);
                        error_username_repet = true;
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
                case 3:
                    KKDialog.getInstance().dismiss();
                    load_progressBar.setVisibility(View.GONE);
                    tv_errorinfo.setText("注册失败,请重试!");
                    break;
                case 1:
                    KKDialog.getInstance().dismiss();
                    load_progressBar.setVisibility(View.GONE);
                    UploadData.getInstance().uploadPushInfo(RegistActivity.this);
                    Toast.makeText(selfContext, "注册成功！（已授权客户端）",
                            Toast.LENGTH_SHORT).show();
                    finish();
                    if (AllCourseActivity.getAllCourseActivity() != null) {
                        AllCourseActivity.getAllCourseActivity().finish();
                    }
                    if (Constants.LOGIN_FROM == Constants.FROM_ALLCOURSE) {
                        Intent intent2 = new Intent(RegistActivity.this, TabCourseActivity.class);
                        intent2.putExtra("isSuccess", true);
                        intent2.putExtra("isFirst", true);
                        startActivity(intent2);
                    }
                    break;
                case 2:
                    KKDialog.getInstance().dismiss();
                    load_progressBar.setVisibility(View.GONE);
                    tv_errorinfo.setText((String) msg.obj);
                    break;
                default:
                    break;
            }
        }

        ;
    };
    private BitmapUtils bitmapUtils;
    private TextView complete_user_info;
    private UMSocialService mloginController;
    private Context context;
    private String email;
    private String password;
    UploadFileUtil.OnUploadProcessListener uploadProcessListener = new UploadFileUtil.OnUploadProcessListener() {

        @Override
        public void onUploadProcess(int uploadSize) {
            // TODO Auto-generated method stub

        }

        @Override
        public void onUploadDone(int responseCode, String message) {
            // TODO Auto-generated method stub
//            mHandler.sendEmptyMessage(MessageConfig.SendSuccess);
            Log.i(tag, "上传了完成");
            Log.i(tag, "上传了完成" + "响应码：" + responseCode + "\n响应信息：" + message
                    + "\n耗时：" + UploadFileUtil.getRequestTime() + "秒");
            if (responseCode == 1) {
                if (message != null) {
                    ErrorInfo errorInfo = (ErrorInfo) JsonEngine.parseJson(message, ErrorInfo.class);
                    if (errorInfo != null && !errorInfo.getStatus()) {
                        Message msg = Message.obtain();
                        msg.obj = errorInfo.getMessage();
                        msg.what = 2;
                        handler.sendMessage(msg);
                        return;
                    }
                    User responseUser = (User) JsonEngine.parseJson(message, User.class);
                    /** 上传成功 */
                    if (responseUser.getId() != 0) {
                        API.getAPI().writeUserInfo2SP(responseUser, password);
                        handler.sendEmptyMessage(1);
                    }
                }
            } else {
                handler.sendEmptyMessage(3);
            }

        }

        @Override
        public void initUpload(int fileSize) {
            // TODO Auto-generated method stub
            Log.i(tag, "图片大小uploadSize:" + fileSize / 1024 / 1024 + "M");
        }
    };
    private String username;
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.signup);
        context = this;
        actionmap = new HashMap<String, String>();
        iv_email_error = (ImageView) findViewById(R.id.iv_email_error);
        iv_password_error = (ImageView) findViewById(R.id.iv_password_error);
        iv_nil_error = (ImageView) findViewById(R.id.iv_nil_error);
        load_progressBar = (ProgressBar) findViewById(R.id.load_progressBar);

        bitmapUtils = BitmapHelp.getBitmapUtils(getApplicationContext());

        selfContext = this;

//		tv_signin = (TextView) findViewById(R.id.tv_signin);
//		tv_signin.setOnClickListener(new OnClickListener() {
//
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//                actionmap.put("goto_signin","");
//				Intent intent = new Intent(selfContext, LoginActivity2 .class);
//				if (Constants.LOGIN_FROM == Constants.FROM_PAY) intent.putExtra(ContextUtil.CATEGORY_COURSE, getIntent().getSerializableExtra(ContextUtil.CATEGORY_COURSE));
//                intent.putExtra(Constants.ACTIVITY_NAME_KEY,"regist_activity");
//				startActivity(intent);
//				finish();
//			}
//		});
        imgAvatar = (ImageView) findViewById(R.id.imgSignupAvatar);
        imgAvatar.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                isChoose = true;
                actionmap.put("add_avatar_btn", "");
                spinner.performClick();
            }
        });

        iv_regist_back = (ImageView) findViewById(R.id.iv_back);
        iv_regist_back.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                actionmap.put("goback", "");
                finish();
            }
        });

        etEmail = (EditText) findViewById(R.id.et_regist_email);
        etPassword = (EditText) findViewById(R.id.et_regist_password);
        etNickName = (EditText) findViewById(R.id.et_nil_truename);
        etEmail.setOnFocusChangeListener(emailFocusListener);
        etPassword.setOnFocusChangeListener(pwdFocusListener);
        etNickName.setOnFocusChangeListener(userNameFocusListener);
        btnAction = (TextView) findViewById(R.id.tv_signup);

        spinner = (Spinner) findViewById(R.id.spinner);
        // 将可选内容与ArrayAdapter连接起来
        adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, selectType);

        // 设置下拉列表的风格
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        // 将adapter 添加到spinner中
        spinner.setAdapter(adapter);

        // 添加事件Spinner事件监听
        spinner.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {
                if (!isChoose) {
                    return;
                }
                if (position == 1) {
                    Intent intent = new Intent(Intent.ACTION_PICK, null);
                    intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                            IMAGE_UNSPECIFIED);
                    startActivityForResult(intent, PHOTOZOOM);

                } else if (position == 2) {
                    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                    intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(Environment.getExternalStorageDirectory(), userAvatarFileName)));
                    startActivityForResult(intent, PHOTOHRAPH);
                }
                spinner.setSelection(0);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // TODO Auto-generated method stub

            }

        });
        btnAction.setOnClickListener(new View.OnClickListener() {
            // TODO
            @Override
            public void onClick(View v) {
                email = etEmail.getText().toString();
                password = etPassword.getText().toString();
                username = etNickName.getText().toString();
                final String confirmed_at = DateUtils.getCurrentTime();
                ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)).
                        hideSoftInputFromWindow(
                                RegistActivity.this.getCurrentFocus().getWindowToken(),
                                InputMethodManager.HIDE_NOT_ALWAYS);
                try {
                    checkInput(email, password, username);
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                    return;
                }

                if (NetworkUtil.isNetworkAvailable(RegistActivity.this)) {
                    KKDialog.getInstance().showProgressBar(RegistActivity.this, KKDialog.IS_LOADING);
                    toUploadFileAndRegist(username, email,
                            password, "mobile", userAvatarFile);
                } else {
                    Toast.makeText(RegistActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                }

//                if(userAvatarFile != null){

//                }else{
//                    new Thread() {
//                        @Override
//                        public void run() {
//                            // TODO Auto-generated method stub
//                            try {
//                                actionmap.put("enter", "setting");
//
//                                User user = UsersAPI.signupUser(nickname, email,
//                                        password,confirmed_at,"mobile",userAvatarFile);
//                                actionmap.put("user_id", user.getId() + "");
//                                actionmap.put("signup_succeed", "true");
//                                handler.sendEmptyMessage(1);
//                            } catch (DibitsExceptionC e) {
//                                actionmap.put("signup_failed","true");
//                                MobclickAgent.onEvent(RegistActivity.this, "signup", actionmap);//友盟统计登陆发生事件
//                                e.printStackTrace();
//                                Message msg = Message.obtain();
//                                msg.obj = e;
//                                msg.what = 0;
//                                handler.sendMessage(msg);
//                                return;
//                            } catch (IOException e) {
//                                actionmap.put("signup_failed","true");
//                                e.printStackTrace();
//                            }
//                            MobclickAgent.onEvent(RegistActivity.this, "signup", actionmap);//友盟统计登陆发生事件
//                        }
//                    }.start();
//                }
            }
        });
        tv_errorinfo = (TextView) findViewById(R.id.tv_errorinfo);

        complete_user_info = (TextView) findViewById(R.id.tv_text);
        mloginController = UMLoginController.getController().getUMSocialService(this);
        if (getIntent().getBooleanExtra("OauthVerify", false)) {
            showComUserInfo();
            getUserInfo((SHARE_MEDIA) getIntent().getExtras().get("SHARE_MEDIA"));
        } else {
            showNoComUserInfo();
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("signup"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("signup");
        MobclickAgent.onPause(this);
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
                error_email_repet = false;
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
            case PASSWORD_ERROR_CHINESE:
                printError(iv_password_error, "密码中不能包含中文！");
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
                printError(iv_nil_error, "用户名不能为空！");
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
                error_username_repet = false;
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
        if (error_email_repet) {
            printError(iv_email_error, "Email error");
        }
        if (error_username_repet) {
            printError(iv_nil_error, "UserName error");
        }
    }

    private void setError(final ImageView v) {
        v.post(new Runnable() {
            @SuppressWarnings("deprecation")
            @Override
            public void run() {
                // TODO Auto-generated method stub
                v.setVisibility(View.VISIBLE);
                v.setImageDrawable(getResources().getDrawable(R.drawable.validate_false));
            }
        });
    }

    private void setTrue(final ImageView v) {
        v.post(new Runnable() {
            @SuppressWarnings("deprecation")
            @Override
            public void run() {
                // TODO Auto-generated method stub
//				v.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_true));
                v.setVisibility(View.VISIBLE);
                v.setImageDrawable(getResources().getDrawable(R.drawable.validate_true));
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (resultCode == NONE)
            return;
        // 拍照
        if (requestCode == PHOTOHRAPH) {
            // 设置文件保存路径这里放在跟目录下
            userAvatarFile = new File(Environment.getExternalStorageDirectory(), userAvatarFileName);
            System.out.println("------------------------"
                    + userAvatarFile.getPath());
            startPhotoZoom(Uri.fromFile(userAvatarFile));
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
                    @SuppressWarnings("deprecation")
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
//						iv_head_error.setVisibility(View.VISIBLE);
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        photo.compress(Bitmap.CompressFormat.PNG, 75, stream);// (0
                        // -
                        // 100)压缩文件
                        try {
                            userAvatarFile = ImgLoaderUtil.writePic2SDCard(
                                    photo, userAvatarFileName);
                        } catch (Exception e) {
                            e.printStackTrace();
//							iv_head_error.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_false));
                            Toast.makeText(selfContext, "图片获取有误，请重试。",
                                    Toast.LENGTH_SHORT).show();
                            return;
                        }
                        // imgAvatar.setImageBitmap(photo);
                        imgAvatar.setImageDrawable(new BitmapDrawable(
                                getResources(), photo));
//						iv_head_error.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_true));
                        actionmap.put("added_avatar", "");
                        // imgAvatar.setBackgroundDrawable(new
                        // BitmapDrawable(photo));
                        // btnAction.setText("修改头像");
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

    public void getUserInfo(SHARE_MEDIA media) {
        mloginController.getPlatformInfo(context,media,new SocializeListeners.UMDataListener() {
            @Override
            public void onStart() {

            }

            @Override
            public void onComplete(int status, final Map<String, Object> info) {
                if(status == 200 && info != null){
                    etNickName.setText(info.get("screen_name").toString());
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                final URL imageUrl = new URL(info.get("profile_image_url").toString());
                                photo = ImageUtils.getBitmap(context, imageUrl);
                                userAvatarFile = new File(Environment.getExternalStorageDirectory(), userAvatarFileName);
                                ByteArrayOutputStream stream = new ByteArrayOutputStream();
                                photo.compress(Bitmap.CompressFormat.PNG, 75, stream);// (0
                                // -
                                // 100)压缩文件
                                try {
                                    userAvatarFile = ImgLoaderUtil.writePic2SDCard(
                                            photo, userAvatarFileName);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    return;
                                }
                                handler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        imgAvatar.setImageDrawable(new BitmapDrawable(getResources(), photo));
                                    }
                                });
                            } catch (MalformedURLException e) {
                                e.printStackTrace();
                            }
                        }
                    }).start();
//                    StringBuilder sb = new StringBuilder();
//                    Set<String> keys = info.keySet();
//                    for(String key : keys){
//                        sb.append(key+"="+info.get(key).toString()+"\r\n");
//                    }
//                    Log.d("TestData",sb.toString());
                }else{
                    Log.d("TestData","发生错误："+status);
                }
            }
        });
    }

    public void showComUserInfo() {
        btnAction.setText(getResources().getString(R.string.finish));
        complete_user_info.setText("完善个人信息");
    }

    public void showNoComUserInfo() {
        btnAction.setText(getResources().getString(R.string.regist));
        complete_user_info.setText("注册");
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
    }

    /**
     * 有文件头像上传
     */
    private void toUploadFileAndRegist(String username, String email, String password, String from, final File avatarFile)

    {
        final String fileKey = "file";
        final String requestURL = HttpUrlUtil.REGISTER;//"https://api.kaikeba.com/v1/user/register" ;
        final UploadFileUtil uploadUtil = UploadFileUtil.getInstance();

        uploadUtil.setOnUploadProcessListener(uploadProcessListener); // 设置监听器监听上传状态
        final Map<String, String> params = new HashMap<String, String>();
        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(RegistActivity.this, "");
        params.put("username", username);
        params.put("email", email);
        params.put("password", password);
        params.put("from", from);
        params.put("action", "register");
        params.put("channel", logininfo.getChannel());
        params.put("client_version", logininfo.getClient_version());
        params.put("imei", logininfo.getImei());
        params.put("mac", logininfo.getMac());
        params.put("model", logininfo.getModel());
        params.put("os_version", logininfo.getOs_version());
        params.put("package_name", logininfo.getPackage_name());
        params.put("platform", logininfo.getPlatform());
        params.put("user_id", logininfo.getUser_id());
        params.put("time_action", logininfo.getTime_action() + "");
        new Thread(new Runnable() {  //开启线程上传文件

            public void run() {
                try {
                    if (avatarFile != null) {
                        uploadUtil.uploadFile(avatarFile, fileKey, requestURL, params);
                    } else {
                        uploadUtil.signupUser(requestURL, params);
                    }
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                    return;
                }
            }
        }).start();
    }

}
