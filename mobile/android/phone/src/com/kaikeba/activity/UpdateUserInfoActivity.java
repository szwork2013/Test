package com.kaikeba.activity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.ErrorInfo;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class UpdateUserInfoActivity extends BaseActivity {
    public static final int NONE = 0;
    public static final int PHOTOHRAPH = 1;// 拍照
    public static final int PHOTOZOOM = 2; // 缩放
    public static final int PHOTORESOULT = 3;// 结果
    private final static String tag = "UpdateUserInfoActivity";
    private static final String[] selectType = {"请选择", "相册", "拍照"};
    private static final String IMAGE_UNSPECIFIED = "image/*";
    User responseUser;
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
                        msg.what = 3;
                        handler.sendMessage(msg);
                        return;
                    }
                    responseUser = (User) JsonEngine.parseJson(message, User.class);
                    /** 上传成功 */
                    if (responseUser.getId() != 0) {
                        API.getAPI().writeUserInfo2SP(responseUser, API.getAPI().getUserObject().getPassword());
                        handler.sendEmptyMessage(2);
                    }
                }
            } else {
                handler.sendEmptyMessage(4);
            }

        }

        @Override
        public void initUpload(int fileSize) {
            // TODO Auto-generated method stub
            Log.i(tag, "图片大小uploadSize:" + fileSize / 1024 / 1024 + "M");
        }
    };
    private ImageView imgSignupAvatar;
    private ImageView tvChangeAvatar;
    private EditText etUserName;
    private EditText etEmail;
    private TextView tvSuccessChange;
    private TextView tv_errorinfo;
    private File userAvatarFile;
    private String userAvatarFileName = "userTempAvatar.png";
    ;
    private Spinner spinner;
    private ArrayAdapter<String> adapter;
    private boolean isChoose = false;
    private Bitmap photo;
    private ImageView btn_back_normal;
    private BitmapUtils bitmapUtils;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                /*Toast.makeText(UpdateUserInfoActivity.this,
						((DibitsExceptionC)msg.obj).getMessageX(), Toast.LENGTH_LONG).show();*/
                    tv_errorinfo.setText(((DibitsExceptionC) msg.obj).getMessageX());
                    break;
                case 1:
                    Toast.makeText(UpdateUserInfoActivity.this,
                            "图片处理有误，请检查图片后重新提交。", Toast.LENGTH_LONG).show();
                    break;
                case 2:
                    KKDialog.getInstance().dismiss();
                    Toast.makeText(UpdateUserInfoActivity.this, "修改成功！",
                            Toast.LENGTH_SHORT).show();
                    // 修改图片成功 删除之前的缓存图片
                    bitmapUtils.clearCache(responseUser.getAvatarUrl());
                    finish();
                    break;
                case 3:
                    KKDialog.getInstance().dismiss();
                    tv_errorinfo.setText((String) msg.obj);
                    break;
                case 4:
                    KKDialog.getInstance().dismiss();
                    tv_errorinfo.setText("修改失败,请重试!");
                    break;
                default:
                    break;
            }
        }

        ;
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.edit_user_profile);
        initView();
        BitmapManager bitmapManager = new BitmapManager();
        bitmapUtils = BitmapHelp.getBitmapUtils(this);
//        userAvatarFile = new File(Environment.getExternalStorageDirectory() + File.separator + "imageCache", userAvatarFileName);
        if (API.getAPI().getUserObject().getAvatarUrl() != null) {
            /*bitmapManager.loadBitmap(API.getAPI().getUserObject().getAvatarUrl(),
                    imgSignupAvatar);*/
            bitmapUtils.display(imgSignupAvatar, API.getAPI().getUserObject().getAvatarUrl());
        }
        etEmail.setText(API.getAPI().getUserObject().getEmail());

        etUserName.setText(API.getAPI().getUserObject().getUserName());
        etUserName.setSelection(etUserName.getText().length());

        tvChangeAvatar.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                isChoose = true;
                spinner.performClick();
            }
        });

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
                    intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri
                            .fromFile(new File(Environment
                                    .getExternalStorageDirectory(),
                                    userAvatarFileName)));
                    startActivityForResult(intent, PHOTOHRAPH);
                }
                spinner.setSelection(0);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // TODO Auto-generated method stub

            }

        });

        tvSuccessChange.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                final String email = etEmail.getText().toString();
                final String nickname = etUserName.getText().toString();

                ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)).
                        hideSoftInputFromWindow(
                                UpdateUserInfoActivity.this.getCurrentFocus().getWindowToken(),
                                InputMethodManager.HIDE_NOT_ALWAYS);
                try {
                    checkUserNameInput(nickname);
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                    return;
                }
                if (NetworkUtil.isNetworkAvailable(UpdateUserInfoActivity.this)) {
                    KKDialog.getInstance().showProgressBar(UpdateUserInfoActivity.this, KKDialog.IS_LOADING);
                    toUploadFileAndRegist(nickname, userAvatarFile);
                } else {
                    Toast.makeText(UpdateUserInfoActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                }
            }
        });
    }

    private void printError(String msg) throws DibitsExceptionC {
        throw new DibitsExceptionC(DEC.Syntax.USER_EMAIL, msg);
    }

    protected void checkUserNameInput(String userName) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserNameErrorInfo(userName);
        switch (checkErrorInput) {
            case USER_ERROR_EMPTY:
                printError("用户不能为空！");
                break;
            case USER_ERROR_LENGTH:
                printError("用户名长度必须为3-18位！");
                break;
            case USER_ERROR_ILLEGAL:
                printError("用户名不规范：用户名由中英文、数字、下划线组成！");
                break;
            case SUCCESS:
                break;
            default:
                break;
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("UpdateUserInfo"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }
//	protected void checkInput(String email, String password, String nickname) throws DibitsExceptionC {
//		// TODO 验证抛异常
//		System.out.println(email);
//		System.out.println(password);
//		System.out.println(nickname);
//		if (!Syntax.checkUserEmail(email)) {
//			throw new DibitsExceptionC(DEC.Syntax.USER_EMAIL, "邮箱填写不合规，请修改后再试");
//		}
//		if (!Syntax.checkUserPassword(password)) {
//			throw new DibitsExceptionC(DEC.Syntax.USER_PASSWORD,
//					"密码填写不合规，不得少于6位，只允许字母、字符和符号");
//		}
//		if (!Syntax.checkUserName(nickname)) {
//			throw new DibitsExceptionC(DEC.Syntax.USER_NICKNAME,
//					"昵称填写不合规，3~20个英文(2~6个中文)，不能包含特殊字符");
//		}
//	}

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("UpdateUserInfo");
        MobclickAgent.onPause(this);
    }

    private void initView() {
        imgSignupAvatar = (ImageView) findViewById(R.id.imgSignupAvatar);
        tvChangeAvatar = (ImageView) findViewById(R.id.tv_change_avatar);
        etUserName = (EditText) findViewById(R.id.et_username);
        etEmail = (EditText) findViewById(R.id.et_email);
        tvSuccessChange = (TextView) findViewById(R.id.tv_success_change);
        spinner = (Spinner) findViewById(R.id.spinner);
        btn_back_normal = (ImageView) findViewById(R.id.iv_back);
        TextView TextView = (TextView) findViewById(R.id.tv_text);
        tv_errorinfo = (TextView) findViewById(R.id.tv_errorinfo);
        TextView.setText("个人信息");
        btn_back_normal.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                finish();
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
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        photo.compress(Bitmap.CompressFormat.PNG, 75, stream);// (0
                        // -
                        // 100)压缩文件
                        try {
                            userAvatarFile = ImgLoaderUtil.writePic2SDCard(
                                    photo, userAvatarFileName);
                        } catch (Exception e) {
                            e.printStackTrace();
                            Toast.makeText(UpdateUserInfoActivity.this, "图片获取有误，请重试。",
                                    Toast.LENGTH_SHORT).show();
                            return;
                        }
                        imgSignupAvatar.setImageBitmap(photo);
//						imgSignupAvatar.setBackgroundDrawable(new BitmapDrawable(getResources(), photo));
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

    /**
     * 有文件头像上传
     */
    private void toUploadFileAndRegist(String username, final File avatarFile)

    {
        final String fileKey = "file";
        final String requestURL = HttpUrlUtil.MODIFY;//"https://api.kaikeba.com/v1/user/modify" ;
        final UploadFileUtil uploadUtil = UploadFileUtil.getInstance();

        uploadUtil.setOnUploadProcessListener(uploadProcessListener); // 设置监听器监听上传状态
        final Map<String, String> params = new HashMap<String, String>();
        params.put("username", username);
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
