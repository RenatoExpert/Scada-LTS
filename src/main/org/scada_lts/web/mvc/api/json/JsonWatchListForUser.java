package org.scada_lts.web.mvc.api.json;

import com.serotonin.mango.view.ShareUser;
import com.serotonin.mango.vo.DataPointVO;
import com.serotonin.mango.vo.User;
import com.serotonin.mango.vo.WatchList;
import com.serotonin.mango.vo.permission.Permissions;
import org.scada_lts.dao.model.ScadaObjectIdentifier;

import java.util.List;
import java.util.stream.Collectors;

import static org.scada_lts.permissions.service.GetDataPointsWithAccess.filteringByAccess;

public class JsonWatchListForUser {

    private int userId;
    private int id;
    private String xid;
    private String name;
    private List<DataPointOnWatchListForUser> pointList;
    private int accessType;

    public JsonWatchListForUser(WatchList watchList, User user) {
        this.id = watchList.getId();
        this.xid = watchList.getXid();
        this.name = watchList.getName();
        this.userId = watchList.getUserId();
        this.pointList = filteringByAccess(user, watchList.getPointList()).stream()
                .map(point -> new DataPointOnWatchListForUser(point, getType(user, point)))
                .collect(Collectors.toList());
        this.accessType = watchList.getUserAccess(user);
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getXid() {
        return xid;
    }

    public void setXid(String xid) {
        this.xid = xid;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<DataPointOnWatchListForUser> getPointList() {
        return pointList;
    }

    public void setPointList(List<DataPointOnWatchListForUser> pointList) {
        this.pointList = pointList;
    }

    public int getAccessType() {
        return accessType;
    }

    public void setAccessType(int accessType) {
        this.accessType = accessType;
    }

    public static class DataPointOnWatchListForUser {

        private ScadaObjectIdentifier identifier;
        private String description;
        private int accessType;

        DataPointOnWatchListForUser(DataPointVO dp, int accessType) {
            this.identifier = dp.toIdentifier();
            this.description = dp.getDescription();
            this.accessType = accessType;
        }

        public ScadaObjectIdentifier getIdentifier() {
            return identifier;
        }

        public void setIdentifier(ScadaObjectIdentifier identifier) {
            this.identifier = identifier;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public int getAccessType() {
            return accessType;
        }

        public void setAccessType(int accessType) {
            this.accessType = accessType;
        }
    }

    private static int getType(User user, DataPointVO dataPoint) {
        if(user.isAdmin())
            return ShareUser.ACCESS_OWNER;
        if(dataPoint.getPointLocator() != null && dataPoint.getPointLocator().isSettable() && Permissions.hasDataPointSetPermission(user, dataPoint))
            return ShareUser.ACCESS_SET;
        if(Permissions.hasDataPointReadPermission(user, dataPoint))
            return ShareUser.ACCESS_READ;
        return ShareUser.ACCESS_NONE;
    }
}
