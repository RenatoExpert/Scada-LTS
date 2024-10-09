<%--
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
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%><%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<c:if test="${!empty events || !noContentWhenEmpty}">
  <c:if test="${displayPagination}">
    <div style="padding:3px; float:left;">
      <c:choose>
        <c:when test="${page == 0}">1</c:when>
        <c:otherwise><a href="#" onclick="doSearch(0);return false;">1</a></c:otherwise>
      </c:choose>
      <c:if test="${leftEllipsis}">...</c:if>
      <c:forEach begin="${linkFrom}" end="${linkTo}" var="i">
        <c:choose>
          <c:when test="${i-1 == page}">${i}</c:when>
          <c:otherwise><a href="#" onclick="doSearch(${i-1});return false;">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>
      <c:if test="${rightEllipsis}">...</c:if>
      <c:choose>
        <c:when test="${page == numberOfPages-1}">${numberOfPages}</c:when>
        <c:otherwise><a href="#" onclick="doSearch(${numberOfPages-1});return false;">${numberOfPages}</a></c:otherwise>
      </c:choose>
      
      <c:choose>
        <c:when test="${page <= 0}">&lt;</c:when>
        <c:otherwise><a href="#" onclick="doSearch(${page-1});return false;">&lt;</a></c:otherwise>
      </c:choose>
      <c:choose>
        <c:when test="${page + 1 >= numberOfPages}">&gt;</c:when>
        <c:otherwise><a href="#" onclick="doSearch(${page+1});return false;">&gt;</a></c:otherwise>
      </c:choose>
    </div>
  </c:if>
  <c:if test="${!empty events && !pendingEvents}">
    <div style="padding:3px; float:left;">
      <c:if test="${displayPagination}">|</c:if>
      <a href="#" onclick="jumpToDate(this);return false;"><sst:i18n key="events.jumpToDate"/></a>
      | <sst:i18n message="${sst:message('events.listed',fn:length(events),'')}" />
    </div>
  </c:if>
  <div style="clear:both;"></div>
  
  <table cellspacing="1" cellpadding="0" border="0">
    <tr class="rowHeader">
      <td><sst:i18n key="events.id"/></td>
      <td><sst:i18n key="common.alarmLevel"/></td>
      <td><sst:i18n key="common.time"/></td>
      <td><sst:i18n key="events.msg"/></td>
      <td><sst:i18n key="common.inactiveTime"/></td>
      <c:if test="${!pendingEvents}"><td><sst:i18n key="events.acknowledged"/></td></c:if>
      <td></td>
    </tr>
    <c:if test="${empty events}"><tr><td colspan="6"><b><sst:i18n key="events.emptyList"/></b></td></tr></c:if>
    <c:forEach items="${events}" var="event" varStatus="status">
      <tr class="rowTable<c:if test="${status.index % 2 == 1}">Alt</c:if>">
        <td align="center">${event.id}</td>
        <td align="center"><tag:eventIcon event="${event}"/></td>
        <td>${sst:time(event.activeTimestamp)}</td>
        <td>
          <table cellspacing="0" cellpadding="0" width="100%">
            <tr>
              <td colspan="2"><b><sst:i18n message="${event.message}"/></b></td>
              <td align="right">
                <a href="#" class="nav-link" title="<fmt:message key='notes.addNote'/>" onclick="openCommentDialog(${applicationScope['constants.UserComment.TYPE_EVENT']}, ${event.id})">
                    <i class="bi bi-chat-dots"></i>
                </a>
              </td>
            </tr>
            <tbody id="eventComments${event.id}"><tag:comments comments="${event.eventComments}"/></tbody>
          </table>
        </td>
        <td>
          <c:choose>
            <c:when test="${event.active}">
              <sst:i18n key="common.active"/>
              <%-- mexi aqui --%>
              <a href="events.shtm" title="<fmt:message key='common.active'/>">
                  <i class="bi bi-flag"></i>
              </a>
            </c:when>
            <c:when test="${!event.rtnApplicable}"><sst:i18n key="common.nortn"/></c:when>
            <c:otherwise>
              ${sst:time(event.rtnTimestamp)} - <sst:i18n message="${event.rtnMessage}"/>
            </c:otherwise>
          </c:choose>
        </td>
        <c:if test="${!pendingEvents}">
          <td>
            <c:if test="${event.acknowledged}">
              ${sst:time(event.acknowledgedTimestamp)}
              <sst:i18n message="${event.ackMessage}"/>
            </c:if>
          </td>
        </c:if>
        <td style="white-space:nowrap;">
          <tag:alarmAck event="${event}"/>
          <c:choose>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.DATA_POINT']}">
            <a href="data_point_details.shtm?dpid=${event.eventType.dataPointId}" title="<fmt:message key='events.pointDetails'/>">
                <i class="bi bi-search text-danger"></i>
            </a>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.DATA_SOURCE']}">
              <a href="data_source_edit.shtm?dsid=${event.eventType.dataSourceId}"><i class="bi bi-database-fill-gear text-danger" title="<fmt:message key='events.editDataSource'/>"></i></a>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.SYSTEM']}">
              <c:choose>
                <c:when test="${event.eventType.systemEventTypeId == applicationScope['constants.SystemEventType.TYPE_VERSION_CHECK']}">
                  <a href="http://mango.serotoninsoftware.com/download.jsp" target="_blank"><i class="bi bi-file-earmark-arrow-down text-danger" title="<fmt:message key='events.downloadMango'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.systemEventTypeId == applicationScope['constants.SystemEventType.TYPE_COMPOUND_DETECTOR_FAILURE']}">
                  <a href="compound_events.shtm?cedid=${event.eventType.referenceId2}"><i class="bi bi-bell" title="<fmt:message key='events.editCompound'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.systemEventTypeId == applicationScope['constants.SystemEventType.TYPE_SET_POINT_HANDLER_FAILURE']}">
                  <a href="event_handlers.shtm?ehid=${event.eventType.referenceId2}"><i class="bi bi-gear text-danger" title="<fmt:message key='events.editEventHandler'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.systemEventTypeId == applicationScope['constants.SystemEventType.TYPE_POINT_LINK_FAILURE']}">
                  <a href="point_links.shtm?plid=${event.eventType.referenceId2}"><i class="bi bi-arrow-left-right text-danger" title="<fmt:message key='events.editPointLink'/>"></i></a>
                </c:when>
              </c:choose>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.COMPOUND']}">
              <a href="compound_events.shtm?cedid=${event.eventType.compoundEventDetectorId}"><i class="bi bi-bell" title="<fmt:message key='events.editCompound'/>"></i></a>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.SCHEDULED']}">
              <a href="scheduled_events.shtm?seid=${event.eventType.scheduleId}"><i class="bi bi-calendar-check text-danger" title="<fmt:message key='events.editScheduledEvent'/>"></i></a>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.PUBLISHER']}">
              <a href="publisher_edit.shtm?pid=${event.eventType.publisherId}"><i class="bi bi-broadcast-pin text-danger" title="<fmt:message key='events.editPublisher'/>"></i></a>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.AUDIT']}">
              <c:choose>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_DATA_SOURCE']}">
                  <a href="data_source_edit.shtm?dsid=${event.eventType.referenceId2}"><i class="bi bi-database-fill-gear text-danger" title="<fmt:message key='events.editDataSource'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_DATA_POINT']}">
                  <a href="data_point_edit.shtm?dpid=${event.eventType.referenceId2}"><i class="bi bi-pencil-square text-danger" title="<fmt:message key='events.pointEdit'/>"></i></a>
                  <a href="data_source_edit.shtm?pid=${event.eventType.referenceId2}"><i class="bi bi-database-fill-gear text-danger" title="<fmt:message key='events.editDataSource'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_POINT_EVENT_DETECTOR']}">
                  <a href="data_point_edit.shtm?pedid=${event.eventType.referenceId2}"><i class="bi bi-pencil-square text-danger" title="<fmt:message key='events.pointEdit'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_COMPOUND_EVENT_DETECTOR']}">
                  <a href="compound_events.shtm?cedid=${event.eventType.referenceId2}"><i class="bi bi-bell" title="<fmt:message key='events.editCompound'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_SCHEDULED_EVENT']}">
                  <a href="scheduled_events.shtm?seid=${event.eventType.referenceId2}"><i class="bi bi-calendar-check text-danger" title="<fmt:message key='events.editScheduledEvent'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_EVENT_HANDLER']}">
                  <a href="event_handlers.shtm?ehid=${event.eventType.referenceId2}"><i class="bi bi-gear text-danger" title="<fmt:message key='events.editEventHandler'/>"></i></a>
                </c:when>
                <c:when test="${event.eventType.auditEventTypeId == applicationScope['constants.AuditEventType.TYPE_POINT_LINK']}">
                  <a href="point_links.shtm?plid=${event.eventType.referenceId2}"><i class="bi bi-arrow-left-right text-danger" title="<fmt:message key='events.editPointLink'/>"></i></a>
                </c:when>
              </c:choose>
            </c:when>
            <c:when test="${event.eventType.eventSourceId == applicationScope['constants.EventType.EventSources.MAINTENANCE']}">
              <a href="maintenance_events.shtm?meid=${event.eventType.maintenanceId}"><i class="bi bi-wrench-adjustable-circle text-danger" title="<fmt:message key='events.editMaintenanceEvent'/>"></i></a>
            </c:when>
            <c:otherwise>(unknown event source id ${event.eventType.eventSourceId})</c:otherwise>
          </c:choose>
        </td>
      </tr>
    </c:forEach>
  </table>
</c:if>