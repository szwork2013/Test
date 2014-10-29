package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;


public class Module implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = -8421536267107623767L;
    private Integer id;
    private String workflow_state;
    private Integer position;
    private String name;
    private Date unlock_at;
    private Boolean require_sequential_progress;
    private ArrayList<Integer> prerequisite_module_ids;
    private String state;
    private Date completed_at;

    private boolean isDownLoad = false;

    public boolean isDownLoad() {
        return isDownLoad;
    }

    public void setDownLoad(boolean downLoad) {
        isDownLoad = downLoad;
    }

    /**
     * @return the id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @return the workflow_state
     */
    public String getWorkflowState() {
        return workflow_state;
    }

    /**
     * @return the position
     */
    public Integer getPosition() {
        return position;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @return the unlock_at
     */
    public Date getUnlockAt() {
        return unlock_at;
    }

    /**
     * @return the require_sequential_progress
     */
    public Boolean getRequireSequentialProgress() {
        return require_sequential_progress;
    }

    /**
     * @return the prerequisite_module_ids
     */
    public ArrayList<Integer> getPrerequisiteModuleIds() {
        return prerequisite_module_ids;
    }

    /**
     * @return the state
     */
    public String getState() {
        return state;
    }

    /**
     * @return the completed_at
     */
    public Date getCompletedAt() {
        return completed_at;
    }

}
