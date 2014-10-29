package com.kaikeba.common.watcher;


/**
 * Created by chris on 14-7-10.
 */
public interface Watched {
    public void addWatcher(Watcher watcher);

    public void removeWatcher(Watcher watcher);

    public void notifyWatchers(Object obj);
}
