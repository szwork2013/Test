package com.kaikeba.mitv.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.BaseAdapter;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.kaikeba.mitv.objects.CourseCardView;

import java.util.List;

/**
 * Created by kkb on 8/6/14.
 */
public class CourseCardAdapter extends BaseAdapter {
    List<CourseCardItem> courses;
    int selectedViewPosition;
    private Context context;

    public CourseCardAdapter(Context c, List<CourseCardItem> courses) {
        this.context = c;
        this.courses = courses;
    }


    // Returns the number of images
    public int getCount() {
        return courses == null ? 0 : courses.size();
//        return courses == null ? 0 : (courses.size() > 4 ? 4 : courses.size());
    }

    // Returns the ID of an item
    public Object getItem(int position) {
        return courses == null ? null : courses.get(position);
    }

    // Returns the ID of an item
    public long getItemId(int position) {
        return position;
    }

    public void enlargeView(int position) {
        selectedViewPosition = position;
        super.notifyDataSetChanged();
    }

    // Returns an ImageView View
    public View getView(int position, View convertView, ViewGroup parent) {
        CourseCardItem cardItem = courses.get(position);

        CourseCardView cardView;
        if (convertView == null) {
            cardView = new CourseCardView(context, null, cardItem, 10, null);
        } else {
            cardView = (CourseCardView) convertView;
        }

        if (cardItem.getCardWidth() != 0 && cardItem.getCardHeight() != 0) {
            cardView.setLayout(cardItem.getCardWidth(), cardItem.getCardHeight());
        }

        if (selectedViewPosition == position) {
            Animation enlargeAnimation = AnimationUtils.loadAnimation(context, R.anim.enlarge_animation);
            cardView.startAnimation(enlargeAnimation);
        } else {
            cardView.clearAnimation();
        }

        return cardView;
    }
}
