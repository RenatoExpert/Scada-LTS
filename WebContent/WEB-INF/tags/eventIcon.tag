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
--%><%@include file="/WEB-INF/tags/decl.tagf" %><%--
--%><%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %><%--
--%><fmt:setBundle basename="messages" /><%--
--%><%@tag body-content="empty" %><%--
--%><%@attribute name="event" type="com.serotonin.mango.rt.event.EventInstance" rtexprvalue="true" %><%--
--%><%@attribute name="eventBean" type="com.serotonin.mango.web.dwr.beans.EventInstanceBean" %><%--
--%><c:if test="${empty event}"><c:set var="event" value="${eventBean}"/></c:if><%--
--%><c:choose>
  <c:when test="${event.active && event.alarmLevel == 0}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.none'/>">
          <i class="bi bi-flag-fill text-success align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.alarmLevel == 0}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.none.rtn'/>">
          <i class="bi bi-flag text-success align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.active && event.alarmLevel == 1}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.info'/>">
          <i class="bi bi-flag-fill text-primary align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.alarmLevel == 1}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.info.rtn'/>">
          <i class="bi bi-flag text-primary align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.active && event.alarmLevel == 2}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.urgent'/>">
          <i class="bi bi-flag-fill text-warning align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.alarmLevel == 2}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.urgent.rtn'/>">
          <i class="bi bi-flag text-warning align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.active && event.alarmLevel == 3}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.critical'/>">
          <i class="bi bi-flag-fill text-orange align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.alarmLevel == 3}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.critical.rtn'/>">
          <i class="bi bi-flag text-orange align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.active && event.alarmLevel == 4}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.lifeSafety'/>">
          <i class="bi bi-flag-fill text-danger align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:when test="${event.alarmLevel == 4}">
      <a href="#" class="nav-link" title="<fmt:message key='common.alarmLevel.lifeSafety.rtn'/>">
          <i class="bi bi-flag text-danger align-middle ms-3 fs-5"></i>
      </a>
  </c:when>
  <c:otherwise>(<fmt:message key="common.alarmLevel.unknown"/> ${event.alarmLevel})</c:otherwise>
</c:choose>