package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.List;

public class CourseModel implements Serializable {
    protected int id;
    protected int category_id;
    protected int institution_id;
    protected String type;
    protected String name;
    protected String slogan;
    protected String intro;
    protected String desc;
    protected int min_duration;
    protected int max_duration;
    protected int weeks;
    protected boolean recommend;
    protected int rating;
    protected int updated_amount;
    protected String level;
    protected int total_amount;
    protected String supper_class_id;
    protected String promotional_video_url;
    protected String certificate_type;
    protected int view_count;
    protected int video_view_count;
    protected int collections_count;
    protected int enrollments_count;
    protected int evaluations_count;
    protected int base_enrollments_count;
    protected int base_collections_count;
    protected int position;
    protected String status;
    protected String created_at;
    protected String updated_at;
    protected String cover_image;
    protected int number;
    protected List<GuidCourseLMS> lms_course_list;
    protected List<ItemVideo> videos;
    protected List<CourseOutLine> course_outline;
    protected List<String> course_key;
    protected List<TechInfo> tech;
    protected String certificate_img;
    protected List<Integer> recommen;
    //我的导学课中的字段
    protected Lms courses_lms;
    private String school;


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCategory_id() {
        return category_id;
    }

    public void setCategory_id(int category_id) {
        this.category_id = category_id;
    }

    public int getInstitution_id() {
        return institution_id;
    }

    public void setInstitution_id(int institution_id) {
        this.institution_id = institution_id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSlogan() {
        return slogan;
    }

    public void setSlogan(String slogan) {
        this.slogan = slogan;
    }

    public String getIntro() {
        return intro;
    }

    public void setIntro(String intro) {
        this.intro = intro;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public int getMin_duration() {
        return min_duration;
    }

    public void setMin_duration(int min_duration) {
        this.min_duration = min_duration;
    }

    public int getMax_duration() {
        return max_duration;
    }

    public void setMax_duration(int max_duration) {
        this.max_duration = max_duration;
    }

    public int getWeeks() {
        return weeks;
    }

    public void setWeeks(int weeks) {
        this.weeks = weeks;
    }

    public boolean isRecommend() {
        return recommend;
    }

    public void setRecommend(boolean recommend) {
        this.recommend = recommend;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public int getUpdated_amount() {
        return updated_amount;
    }

    public void setUpdated_amount(int updated_amount) {
        this.updated_amount = updated_amount;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public int getTotal_amount() {
        return total_amount;
    }

    public void setTotal_amount(int total_amount) {
        this.total_amount = total_amount;
    }

    public String getSupper_class_id() {
        return supper_class_id;
    }

    public void setSupper_class_id(String supper_class_id) {
        this.supper_class_id = supper_class_id;
    }

    public String getPromotional_video_url() {
        return promotional_video_url;
    }

    public void setPromotional_video_url(String promotional_video_url) {
        this.promotional_video_url = promotional_video_url;
    }

    public String getCertificate_type() {
        return certificate_type;
    }

    public void setCertificate_type(String certificate_type) {
        this.certificate_type = certificate_type;
    }

    public int getView_count() {
        return view_count;
    }

    public void setView_count(int view_count) {
        this.view_count = view_count;
    }

    public int getVideo_view_count() {
        return video_view_count;
    }

    public void setVideo_view_count(int video_view_count) {
        this.video_view_count = video_view_count;
    }

    public int getCollections_count() {
        return collections_count;
    }

    public void setCollections_count(int collections_count) {
        this.collections_count = collections_count;
    }

    public int getEnrollments_count() {
        return enrollments_count;
    }

    public void setEnrollments_count(int enrollments_count) {
        this.enrollments_count = enrollments_count;
    }

    public int getEvaluations_count() {
        return evaluations_count;
    }

    public void setEvaluations_count(int evaluations_count) {
        this.evaluations_count = evaluations_count;
    }

    public int getBase_enrollments_count() {
        return base_enrollments_count;
    }

    public void setBase_enrollments_count(int base_enrollments_count) {
        this.base_enrollments_count = base_enrollments_count;
    }

    public int getBase_collections_count() {
        return base_collections_count;
    }

    public void setBase_collections_count(int base_collections_count) {
        this.base_collections_count = base_collections_count;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(String updated_at) {
        this.updated_at = updated_at;
    }

    public String getCover_image() {
        return cover_image;
    }

    public void setCover_image(String cover_image) {
        this.cover_image = cover_image;
    }

    public List<ItemVideo> getVideos() {
        return videos;
    }

    public void setVideos(List<ItemVideo> videos) {
        this.videos = videos;
    }

    public List<GuidCourseLMS> getLms_course_list() {
        return lms_course_list;
    }

    public void setLms_course_list(List<GuidCourseLMS> lms_course_list) {
        this.lms_course_list = lms_course_list;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public List<CourseOutLine> getCourse_outline() {
        return course_outline;
    }

    public void setCourse_outline(List<CourseOutLine> course_outline) {
        this.course_outline = course_outline;
    }

    public String getCertificate_img() {
        return certificate_img;
    }

    public void setCertificate_img(String certificate_img) {
        this.certificate_img = certificate_img;
    }

    public List<String> getCourse_key() {
        return course_key;
    }

    public void setCourse_key(List<String> course_key) {
        this.course_key = course_key;
    }

    public Lms getCourses_lms() {
        return courses_lms;
    }

    public void setCourses_lms(Lms courses_lms) {
        this.courses_lms = courses_lms;
    }

    public List<Integer> getRecommen() {
        return recommen;
    }

    public void setRecommen(List<Integer> recommen) {
        this.recommen = recommen;
    }

    public List<TechInfo> getTechInfo() {
        return tech;
    }

    public void setTechInfo(List<TechInfo> tech) {
        this.tech = tech;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public static class ItemVideo implements Serializable {
        private int item_id;
        private String item_title;
        private String video_url;
        private boolean isSelected;
        private boolean isLoading;
        private boolean isLoadFailure;

        public int getItemID() {
            return item_id;
        }

        public void setItemID(int itemID) {
            this.item_id = itemID;
        }

        public String getItemTitle() {
            return item_title;
        }

        public void setItemTitle(String itemTitle) {
            this.item_title = itemTitle;
        }

        public String getVideoURL() {
            return video_url;
        }

        public void setVideoURL(String videoURL) {
            this.video_url = videoURL;
        }

        public boolean getIsSelected() {
            return isSelected;
        }

        public void setIsSelected(boolean isSelected) {
            this.isSelected = isSelected;
        }

        public boolean getIsLoading() {
            return isLoading;
        }

        public void setIsLoading(boolean isLoading) {
            this.isLoading = isLoading;
        }

        public boolean isLoadFailure() {
            return isLoadFailure;
        }

        public void setLoadFailure(boolean isLoadFailure) {
            this.isLoadFailure = isLoadFailure;
        }
    }

    public static class CourseOutLine implements Serializable {
        private int id;
        private int course_id;
        private int lms_course_id;
        private String name;
        private int position;
        private String unlock_at;
        private String workflow_state;
        private boolean require_sequential_progress;
        private List<Long> prerequisite_module_ids;
        private String state;
        private String completed_at;
        private List<Item> items;
        private String start_at;
        private String conclude_at;
        private String status;
        private String created_at;
        private String updated_at;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public int getCourse_id() {
            return course_id;
        }

        public void setCourse_id(int course_id) {
            this.course_id = course_id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getPosition() {
            return position;
        }

        public void setPosition(int position) {
            this.position = position;
        }

        public String getUnlock_at() {
            return unlock_at;
        }

        public void setUnlock_at(String unlock_at) {
            this.unlock_at = unlock_at;
        }

        public String getWorkflow_state() {
            return workflow_state;
        }

        public void setWorkflow_state(String workflow_state) {
            this.workflow_state = workflow_state;
        }

        public boolean isRequire_sequential_progress() {
            return require_sequential_progress;
        }

        public void setRequire_sequential_progress(boolean require_sequential_progress) {
            this.require_sequential_progress = require_sequential_progress;
        }

        public List<Long> getPrerequisite_module_ids() {
            return prerequisite_module_ids;
        }

        public void setPrerequisite_module_ids(List<Long> prerequisite_module_ids) {
            this.prerequisite_module_ids = prerequisite_module_ids;
        }

        public String getState() {
            return state;
        }

        public void setState(String state) {
            this.state = state;
        }

        public String getCompleted_at() {
            return completed_at;
        }

        public void setCompleted_at(String completed_at) {
            this.completed_at = completed_at;
        }

        public List<Item> getItems() {
            return items;
        }

        public void setItems(List<Item> items) {
            this.items = items;
        }

        public int getLms_course_id() {
            return lms_course_id;
        }

        public void setLms_course_id(int lms_course_id) {
            this.lms_course_id = lms_course_id;
        }

        public String getStart_at() {
            return start_at;
        }

        public void setStart_at(String start_at) {
            this.start_at = start_at;
        }

        public String getConclude_at() {
            return conclude_at;
        }

        public void setConclude_at(String conclude_at) {
            this.conclude_at = conclude_at;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getCreated_at() {
            return created_at;
        }

        public void setCreated_at(String created_at) {
            this.created_at = created_at;
        }

        public String getUpdated_at() {
            return updated_at;
        }

        public void setUpdated_at(String updated_at) {
            this.updated_at = updated_at;
        }
    }

    public static class Item implements Serializable {
        private int id;
        private int parent_id;
        private int indent;
        private int position;
        private String title;
        private String type;
        private String html_url;
        private String url;
        private Requirement completion_requirement;
        private String downloadState;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public int getParent_id() {
            return parent_id;
        }

        public void setParent_id(int parent_id) {
            this.parent_id = parent_id;
        }

        public int getPosition() {
            return position;
        }

        public void setPosition(int position) {
            this.position = position;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public int getIndent() {
            return indent;
        }

        public void setIndent(int indent) {
            this.indent = indent;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getHtml_url() {
            return html_url;
        }

        public void setHtml_url(String html_url) {
            this.html_url = html_url;
        }

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public Requirement getCompletion_requirement() {
            return completion_requirement;
        }

        public void setCompletion_requirement(Requirement completion_requirement) {
            this.completion_requirement = completion_requirement;
        }

        public String getDownloadState() {
            return downloadState;
        }

        public void setDownloadState(String downloadState) {
            this.downloadState = downloadState;

        }

        public static class Requirement implements Serializable {
            private String type;

            public String getType() {
                return type;
            }

            public void setType(String type) {
                this.type = type;
            }
        }

    }

    public static class Lms implements Serializable {
        private int account_id;
        private String course_code;
        private String default_view;
        private int id;
        private String name;
        private String start_at;
        private String end_at;
        private Calendar calendar;
        private List<Enrollment> enrollments;
        private boolean hide_final_grades;
        private String enroll_at;

        public int getAccount_id() {
            return account_id;
        }

        public void setAccount_id(int account_id) {
            this.account_id = account_id;
        }

        public String getCourse_code() {
            return course_code;
        }

        public void setCourse_code(String course_code) {
            this.course_code = course_code;
        }

        public String getDefault_view() {
            return default_view;
        }

        public void setDefault_view(String default_view) {
            this.default_view = default_view;
        }

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getStart_at() {
            return start_at;
        }

        public void setStart_at(String start_at) {
            this.start_at = start_at;
        }

        public List<Enrollment> getEnrollments() {
            return enrollments;
        }

        public void setEnrollments(List<Enrollment> enrollments) {
            this.enrollments = enrollments;
        }

        public String getEnd_at() {
            return end_at;
        }

        public void setEnd_at(String end_at) {
            this.end_at = end_at;
        }

        public Calendar getCalendar() {
            return calendar;
        }

        public void setCalendar(Calendar calendar) {
            this.calendar = calendar;
        }

        public boolean getHide_final_grades() {
            return hide_final_grades;
        }

        public void setHide_final_grades(boolean hide_final_grades) {
            this.hide_final_grades = hide_final_grades;
        }

        public String getEnroll_at() {
            return enroll_at;
        }

        public void setEnroll_at(String enroll_at) {
            this.enroll_at = enroll_at;
        }
    }

    public static class Calendar implements Serializable {
        private String ics;

        public String getIcs() {
            return ics;
        }

        public void setIcs(String ics) {
            this.ics = ics;
        }
    }

    public static class Enrollment implements Serializable {
        private String type;
        private String role;

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }
    }

    public static class GuidCourseLMS implements Serializable {
        private long id;
        private long course_id;
        private int lms_course_id;
        private String name;
        private String start_at;
        private String conclude_at;
        private String position;
        private String status;
        private String created_at;
        private String updated_at;
        private int opened_weeks;
        private List<CourseArrange> course_arrange;

        public long getId() {
            return id;
        }

        public void setId(long id) {
            this.id = id;
        }

        public long getCourse_id() {
            return course_id;
        }

        public void setCourse_id(long course_id) {
            this.course_id = course_id;
        }

        public int getLms_course_id() {
            return lms_course_id;
        }

        public void setLms_course_id(int lms_course_id) {
            this.lms_course_id = lms_course_id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getStart_at() {
            return start_at;
        }

        public void setStart_at(String start_at) {
            this.start_at = start_at;
        }

        public String getConclude_at() {
            return conclude_at;
        }

        public void setConclude_at(String conclude_at) {
            this.conclude_at = conclude_at;
        }

        public String getPosition() {
            return position;
        }

        public void setPosition(String position) {
            this.position = position;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getCreated_at() {
            return created_at;
        }

        public void setCreated_at(String created_at) {
            this.created_at = created_at;
        }

        public String getUpdated_at() {
            return updated_at;
        }

        public void setUpdated_at(String updated_at) {
            this.updated_at = updated_at;
        }

        public int getOpened_weeks() {
            return opened_weeks;
        }

        public void setOpened_weeks(int opened_weeks) {
            this.opened_weeks = opened_weeks;
        }

        public List<CourseArrange> getCourse_arrange() {
            return course_arrange;
        }

        public void setCourse_arrange(List<CourseArrange> course_arrange) {
            this.course_arrange = course_arrange;
        }
    }

    public static class CourseArrange implements Serializable {
        private long id;
        private long course_id;
        private String name;
        private String position;
        private String unlock_at;
        private String workflow_state;
        private String require_sequential_progress;
        private List<Long> prerequisite_module_ids;
        private List<Items> items;
        private boolean isGroupSelected;

        public long getId() {
            return id;
        }

        public void setId(long id) {
            this.id = id;
        }

        public long getCourse_id() {
            return course_id;
        }

        public void setCourse_id(long course_id) {
            this.course_id = course_id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getPosition() {
            return position;
        }

        public void setPosition(String position) {
            this.position = position;
        }

        public String getUnlock_at() {
            return unlock_at;
        }

        public void setUnlock_at(String unlock_at) {
            this.unlock_at = unlock_at;
        }

        public String getWorkflow_state() {
            return workflow_state;
        }

        public void setWorkflow_state(String workflow_state) {
            this.workflow_state = workflow_state;
        }

        public String getRequire_sequential_progress() {
            return require_sequential_progress;
        }

        public void setRequire_sequential_progress(String require_sequential_progress) {
            this.require_sequential_progress = require_sequential_progress;
        }

        public List<Long> getPrerequisite_module_ids() {
            return prerequisite_module_ids;
        }

        public void setPrerequisite_module_ids(List<Long> prerequisite_module_ids) {
            this.prerequisite_module_ids = prerequisite_module_ids;
        }

        public List<Items> getItems() {
            return items;
        }

        public void setItems(List<Items> items) {
            this.items = items;
        }

        public boolean isGroupSelected() {
            return isGroupSelected;
        }

        public void setGroupSelected(boolean isGroupSelected) {
            this.isGroupSelected = isGroupSelected;
        }
    }

    public static class Items implements Serializable {
        private int id;
        private long indent;
        private long position;
        private String title;      //    ": "第01周-导学",
        private String type;       // ": "Page",
        private String html_url;   //   ": "http://learn-test.kaikeba.com/courses/735/modules/items/23900",
        private String url;        //   "http://learn-test.kaikeba.com/api/v1/courses/735/pages/di-02zhou-dao-xue"
        private boolean ischildSelected;
        private boolean isDownLoading;
        private boolean isDownLoadFailure;
        private String downloadState;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public long getIndent() {
            return indent;
        }

        public void setIndent(long indent) {
            this.indent = indent;
        }

        public long getPosition() {
            return position;
        }

        public void setPosition(long position) {
            this.position = position;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getHtml_url() {
            return html_url;
        }

        public void setHtml_url(String html_url) {
            this.html_url = html_url;
        }

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getDownloadState() {
            return downloadState;
        }

        public void setDownloadState(String downloadState) {
            this.downloadState = downloadState;
        }


        public boolean isChildSelected() {
            return ischildSelected;
        }

        public void setIschildSelected(boolean ischildSelected) {
            this.ischildSelected = ischildSelected;
        }

        public boolean isDownLoading() {
            return isDownLoading;
        }

        public void setDownLoading(boolean isDownLoading) {
            this.isDownLoading = isDownLoading;
        }

        public boolean isDownLoadFailure() {
            return isDownLoadFailure;
        }

        public void setDownLoadFailure(boolean isDownLoadFailure) {
            this.isDownLoadFailure = isDownLoadFailure;
        }
    }

    public static class TechInfo implements Serializable {
        private long id;
        private String name;
        private String slogan;
        private String intro;
        private String desc;
        private String sina_weibo;
        private String tx_weibo;
        private long institution_id;
        private String tech_org;
        private String tech_img;

        public long getId() {
            return id;
        }

        public void setId(long id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getSlogan() {
            return slogan;
        }

        public void setSlogan(String slogan) {
            this.slogan = slogan;
        }

        public String getIntro() {
            return intro;
        }

        public void setIntro(String intro) {
            this.intro = intro;
        }

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }

        public String getSina_weibo() {
            return sina_weibo;
        }

        public void setSina_weibo(String sina_weibo) {
            this.sina_weibo = sina_weibo;
        }

        public String getTx_weibo() {
            return tx_weibo;
        }

        public void setTx_weibo(String tx_weibo) {
            this.tx_weibo = tx_weibo;
        }

        public long getInstitution_id() {
            return institution_id;
        }

        public void setInstitution_id(long institution_id) {
            this.institution_id = institution_id;
        }

        public String getTech_org() {
            return tech_org;
        }

        public void setTech_org(String tech_org) {
            this.tech_org = tech_org;
        }

        public String getTech_img() {
            return tech_img;
        }

        public void setTech_img(String tech_img) {
            this.tech_img = tech_img;
        }
    }
}
