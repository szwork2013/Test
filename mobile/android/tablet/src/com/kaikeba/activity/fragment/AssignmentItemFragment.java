package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.activity.ActiveAssigmentActivity;
import com.kaikeba.activity.ActiveDisscussActivity;
import com.kaikeba.activity.ActiveModuleActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.common.entity.Assignment;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.phone.R;

import java.util.ArrayList;

/**
 * 作业详情
 *
 * @author Super Man
 */
@SuppressLint("SetJavaScriptEnabled")
public class AssignmentItemFragment extends Fragment {

    int index = -1;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            int id = v.getId();
            switch (id) {
                case R.id.btn_back_normal:
                    if (getActivity() instanceof ModuleActivity) {
                        getActivity().onBackPressed();
                    } else {
                        if (getActivity() instanceof ActiveDisscussActivity) {
                            ((ActiveDisscussActivity) getActivity()).clickDisscuss();
                        } else if (getActivity() instanceof ActiveModuleActivity) {
                            ((ActiveModuleActivity) getActivity()).clickAnnounce();
                        } else if (getActivity() instanceof ActiveAssigmentActivity) {
                            ((ActiveAssigmentActivity) getActivity()).clickAssignment();
                        }
                    }
                    break;
                case R.id.previous:
                    if (index == 0) {
                        Toast.makeText(getActivity(), "已经是第一个", Toast.LENGTH_SHORT).show();
                    } else {
                        index--;
                        setText();
                    }
                    break;
                case R.id.next:
                    if (index == assignments.size() - 1) {
                        Toast.makeText(getActivity(), "已经是最后一个", Toast.LENGTH_SHORT).show();
                    } else {
                        index++;
                        setText();
                    }
                    break;
                default:
                    break;
            }
        }
    };
    private TextView title;
    private TextView tvDueAt;
    private TextView tvPoint;
    private WebView wvMsg;
    private Assignment assignment;
    private ArrayList<Assignment> assignments;

    @SuppressWarnings("unchecked")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.my_course_assignment_item, container, false);
        findViews(v);
        WebSettings setting = wvMsg.getSettings();
        setting.setUseWideViewPort(true);
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        wvMsg.setWebViewClient(new WebViewClient());
        assignments = (ArrayList<Assignment>) getArguments().getSerializable("assignments");
        if (getActivity() instanceof ModuleActivity) {
            assignment = (Assignment) getArguments().getSerializable("assignment");
            index = assignments.indexOf(assignment);
        } else {
            index = getArguments().getInt("index", 0);
            assignment = assignments.get(index);
        }
        return v;
    }

    private void findViews(View v) {
        v.findViewById(R.id.btn_back_normal).setOnClickListener(listener);
        title = (TextView) v.findViewById(R.id.title);
        tvDueAt = (TextView) v.findViewById(R.id.tv_due_at);
        tvPoint = (TextView) v.findViewById(R.id.tv_point);
        wvMsg = (WebView) v.findViewById(R.id.wv_msg);
        v.findViewById(R.id.previous).setOnClickListener(listener);
        v.findViewById(R.id.next).setOnClickListener(listener);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        setText();
    }

    private void setText() {
        title.setText(assignments.get(index).getName());
        wvMsg.loadDataWithBaseURL(null, assignments.get(index).getDescription(), "text/html", "utf-8", null);

        if (assignments.get(index).getDue_at() != null) {
            tvDueAt.setText(DateUtils.getCourseStartTime(assignments.get(index).getDue_at()));
        } else if (assignments.get(index).getUnlock_at() != null) {
            tvDueAt.setText(DateUtils.getCourseStartTime(assignments.get(index).getUnlock_at()));
        }
//		else if (assignments.get(index).getLock_info() != null && assignments.get(index).getLock_info().getLock_at() != null){
//			tvDueAt.setText(DateUtils.getCourseStartTime(assignments.get(index).getLock_info().getLock_at()));
//		}
        else {
            tvDueAt.setText("");
        }

        tvPoint.setText(assignments.get(index).getPoints_possible());
    }

//	private Handler handler = new Handler(){
//		public void handleMessage(android.os.Message msg) {
//			switch (msg.what) {
//			case 0:
//				break;
//			default:
//				break;
//			}
//		};
//	};

}

