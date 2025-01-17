/*
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.serotonin.mango.vo.mailingList;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.serotonin.mango.rt.event.EventInstance;
import com.serotonin.mango.util.IntervalUtil;
import com.serotonin.timer.CronExpression;
import org.joda.time.DateTime;

import com.serotonin.json.JsonObject;
import com.serotonin.json.JsonReader;
import com.serotonin.json.JsonRemoteEntity;
import com.serotonin.json.JsonRemoteProperty;
import com.serotonin.mango.Common;
import com.serotonin.util.StringUtils;
import com.serotonin.web.dwr.DwrResponseI18n;
import org.scada_lts.service.CommunicationChannelTypable;

@JsonRemoteEntity
public class MailingList extends EmailRecipient {
    public static final String XID_PREFIX = "ML_";

    private int id = Common.NEW_ID;
    @JsonRemoteProperty
    private String xid;
    @JsonRemoteProperty
    private String name;
    @JsonRemoteProperty(innerType = EmailRecipient.class)
    @JsonDeserialize(using = EmailRecipientDeserializer.class)
    private List<EmailRecipient> entries;
    @JsonRemoteProperty
    private String cronPattern;
    @JsonRemoteProperty
    private boolean collectInactiveEmails;
    @JsonRemoteProperty
    private int dailyLimitSentEmailsNumber;
    @JsonRemoteProperty
    private boolean dailyLimitSentEmails;

    /**
     * Integers that are present in the inactive intervals set are times at which the mailing list schedule is not to be
     * sent to. Intervals are split into 15 minutes, starting at [00:00 to 00:15) on Monday. Thus, there are 4 * 24 * 7
     * = 672 individual periods.
     */



    @JsonRemoteProperty(innerType = Integer.class)
    private Set<Integer> inactiveIntervals = new TreeSet<Integer>();

    @Override
    public int getRecipientType() {
        return EmailRecipient.TYPE_MAILING_LIST;
    }

    @Override
    public String getReferenceAddress() {
        return null;
    }

    @Override
    public int getReferenceId() {
        return id;
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

    public List<EmailRecipient> getEntries() {
        return entries;
    }

    public void setEntries(List<EmailRecipient> entries) {
        this.entries = entries;
    }

    public Set<Integer> getInactiveIntervals() {
        return inactiveIntervals;
    }

    public void setInactiveIntervals(Set<Integer> inactiveIntervals) {
        this.inactiveIntervals = inactiveIntervals;
    }

    @Override
    public void appendAddresses(Set<String> addresses, DateTime sendTime) {
        if (sendTime != null && !isActive(sendTime))
            return;
        appendAllAddresses(addresses);
    }

    @Override
    public void appendAllAddresses(Set<String> addresses) {
        for (EmailRecipient e : entries)
            e.appendAddresses(addresses, null);
    }

    @Override
    public void appendAddresses(Set<String> addresses, DateTime sendTime, CommunicationChannelTypable type) {
        if (sendTime != null && !isActive(sendTime))
            return;
        appendAllAddresses(addresses, type);
    }

    @Override
    public void appendAllAddresses(Set<String> addresses, CommunicationChannelTypable type) {
        for (EmailRecipient e : entries)
            e.appendAddresses(addresses, null, type);
    }

    public void validate(DwrResponseI18n response) {
        // Check that required fields are present.
        if (StringUtils.isEmpty(name))
            response.addContextualMessage("name", "mailingLists.validate.nameRequired");

        // Check field lengths
        if (StringUtils.isLengthGreaterThan(name, 40))
            response.addContextualMessage("name", "mailingLists.validate.nameGreaterThan40");

        // Check for entries.
        if (entries.size() == 0)
            response.addGenericMessage("mailingLists.validate.entries");

        if(isCollectInactiveEmails()) {
            try {
                new CronExpression(cronPattern);
            } catch (Exception e) {
                response.addContextualMessage("cronPattern", "mailingLists.validate.correctCron", e.getMessage());
            }
        }
    }

    @Override
    public String toString() {
        return "MailingList(" + entries + ")";
    }

    @Override
    public void jsonSerialize(Map<String, Object> map) {
        // Don't call the super method, because a mailing list can't be a member of a mailing list.
        map.put("xid", xid);
    }

    @Override
    public void jsonDeserialize(JsonReader reader, JsonObject json) {
        // no op
    }

    public String getCronPattern() {
        return cronPattern;
    }

    public void setCronPattern(String cronPattern) {
        this.cronPattern = cronPattern;
    }

    public boolean isCollectInactiveEmails() {
        return collectInactiveEmails;
    }

    public void setCollectInactiveEmails(boolean collectInactiveEmails) {
        this.collectInactiveEmails = collectInactiveEmails;
    }

    public int getDailyLimitSentEmailsNumber() {
        return dailyLimitSentEmailsNumber;
    }

    public void setDailyLimitSentEmailsNumber(int dailyLimitSentEmailsNumber) {
        this.dailyLimitSentEmailsNumber = dailyLimitSentEmailsNumber;
    }

    public boolean isDailyLimitSentEmails() {
        return dailyLimitSentEmails;
    }

    public void setDailyLimitSentEmails(boolean dailyLimitSentEmails) {
        this.dailyLimitSentEmails = dailyLimitSentEmails;
    }

    public boolean isActive(DateTime sendTime) {
        return IntervalUtil.isActiveByInterval(this, sendTime);
    }

    public boolean isActive(EventInstance sendTime) {
        return IntervalUtil.isActiveByInterval(this, sendTime);
    }
}
